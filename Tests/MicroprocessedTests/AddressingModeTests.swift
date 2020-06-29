import XCTest
@testable import Microprocessed

typealias AddressingMode = Instruction.AddressingMode
typealias Opcodes = AddressingMode.Opcodes

final class AddressingModeTests: SystemTests {

    // checks that every single opcode is covered in one (and only one) of the static opcode addressing mode arrays
    func testOpcodesExhaustive() throws {

        let allOpcodes:[UInt8] = [
            Opcodes.absolute,
            Opcodes.absoluteIndexedIndirect,
            Opcodes.absoluteIndexedX,
            Opcodes.absoluteIndexedY,
            Opcodes.absoluteIndrect,
            Opcodes.relative,
            Opcodes.accumulator,
            Opcodes.implied,
            Opcodes.immediate,
            Opcodes.stack,
            Opcodes.unused,
            Opcodes.zeroPage,
            Opcodes.zeroPageIndexedIndirect,
            Opcodes.zeroPageIndexedX,
            Opcodes.zeroPageIndexedY,
            Opcodes.zeroPageIndirect,
            Opcodes.zeroPageIndirectIndexed
        ].flatMap { $0 }

        let allOpcodesSet = Set(allOpcodes)
        /// First, check that every single opcode is covered, either as a real opcode or in the `unused` array
        for opcode in 0..<UInt8.max {
            XCTAssert(allOpcodesSet.contains(opcode), "Missing opcode \(String(format: "0x%X", opcode))")
        }

        /// now check if there are duplicates
        let dupes: [UInt8: Int] = allOpcodes.reduce([:]) { seenOpcodes, opcode in
            var nextSeenOpcodes = seenOpcodes

            if let seen = seenOpcodes[opcode] {
                // dupe
                nextSeenOpcodes[opcode] = seen + 1
            } else {
                nextSeenOpcodes[opcode] = 1
            }

            return nextSeenOpcodes
        }
        .filter { $0.1 > 1 }

        XCTAssert(dupes.count == 0, "Found duplicate opcodes: \(dupes.map { String(format: "0x%X", $0.0) })")
    }

    func testInstructionSize() throws {
        func testOpcode(_ opcode: UInt8, expectedSize: Int) throws -> Bool {
            try ram.write(to: mpu.registers.PC, data: opcode)
            let instr = try mpu.fetch()
            return instr.size == expectedSize
        }

        XCTAssert(try testOpcode(Opcodes.accumulator[0], expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.implied[0], expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.stack[0], expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.immediate[0], expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPage[0], expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.absolute[0], expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.relative[0], expectedSize: 2))
    }

    func testImplied() throws {
        for opcode in Opcodes.implied {
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .implied)
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }

    func testAccumulator() throws {
        for opcode in Opcodes.accumulator {
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .accumulator)
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }

    func testStack() throws {
        for opcode in Opcodes.stack {
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .stack, "Received \(addressingMode)")
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }

    func testImmediate() throws {
        let immediateOpcodes: [UInt8] = Opcodes.immediate

        for opcode in immediateOpcodes {
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: opcode &+ 1)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .immediate(value: opcode &+ 1))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)

            // doesn't support word mode
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }

    func testAbsolute() throws {
        for (index, opcode) in Opcodes.absolute.enumerated() {
            let adjustedAddress = UInt16(0x2000 + index)
            try ram.write(to: adjustedAddress, data: opcode &+ 1)
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(toAddressStartingAt: mpu.registers.PC + 1, word: adjustedAddress)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .absolute(address: adjustedAddress))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)

            // doesn't support word mode
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }

    func testRelative() throws {
        let negativeOffset = Int8(-120)
        let positiveOffset = Int8(120)

        for (index, opcode) in Opcodes.relative.enumerated() {
            let offset = index % 2 == 0 ? positiveOffset : negativeOffset

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: UInt8(bitPattern: offset))

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .relative(offset: offset))

            let resolvedAddress = UInt16(bitPattern: Int16(offset)) &+ mpu.registers.PC
            XCTAssert(try addressingMode.word(from: ram, registers: mpu.registers) == resolvedAddress)
        }
    }

    func testZeroPage() throws {
        let zeroPageOpcodes = Opcodes.zeroPage

        for (index, opcode) in zeroPageOpcodes.enumerated() {
            try ram.write(to: UInt16(index), data: opcode &+ 1)
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: UInt8(index))

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPage(address: UInt8(index)))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)

            // doesn't support word mode
            XCTAssertThrowsError(try addressingMode.word(from: ram, registers: mpu.registers))
        }
    }
}
