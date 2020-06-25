import XCTest
@testable import Microprocessed

typealias AddressingMode = Instruction.AddressingMode
typealias Opcodes = AddressingMode.Opcodes

final class AddressingModeTests: SystemTests {

    // checks that every single opcode is covered in one (and only one) of the static opcode addressing mode arrays
    func testOpcodesExhaustive() throws {

        let allOpcodes: Set<UInt8> = Set([
            Opcodes.absolute,
            Opcodes.absoluteIndexedIndirect,
            Opcodes.absoluteIndexed,
            Opcodes.absoluteIndrect,
            Opcodes.immediate,
            Opcodes.relative,
            Opcodes.accumulator,
            Opcodes.implied,
            Opcodes.immediate,
            Opcodes.stack,
            Opcodes.unused,
            Opcodes.zeroPage,
            Opcodes.zeroPageIndexedIndirect,
            Opcodes.zeroPageIndexed,
            Opcodes.zeroPageIndirect,
            Opcodes.zeroPageIndirectIndexed
            ].flatMap { $0 }
        )

        /// First, check that every single opcode is covered, either as a real opcode or in the `unused` array
        for opcode in 0..<UInt8.max {
            XCTAssert(allOpcodes.contains(opcode), "Missing opcode \(String(format: "0x%X", opcode))")
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

        XCTAssert(dupes.count == 0, "Found duplicate opcodes: \(dupes)")
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
    }

    func testImmediate() throws {
        let immediateOpcodes: [UInt8] = Opcodes.immediate

        for opcode in immediateOpcodes {
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: opcode &+ 1)

            let instr = try mpu.fetch()
            XCTAssert(instr.addressingMode ~= .immediate(value: opcode &+ 1))
        }
    }
}
