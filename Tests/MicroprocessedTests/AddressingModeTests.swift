import XCTest
@testable import Microprocessed

typealias AddressingMode = Instruction.AddressingMode
typealias Opcodes = AddressingMode.Opcodes

final class AddressingModeTests: SystemTests {

    // checks that every single opcode is covered in one (and only one) of the static opcode addressing mode arrays
    func testOpcodesExhaustive() throws {

        let allOpcodes: [UInt8] = [
            Opcodes.absolute,
            Opcodes.absoluteIndexedIndirect,
            Opcodes.absoluteIndexedX,
            Opcodes.absoluteIndexedY,
            Opcodes.absoluteIndirect,
            Opcodes.relative,
            Opcodes.accumulator,
            Opcodes.implied,
            Opcodes.immediate,
            Opcodes.stack,
            Opcodes.zeroPage,
            Opcodes.zeroPageIndexedIndirect,
            Opcodes.zeroPageIndexedX,
            Opcodes.zeroPageIndexedY,
            Opcodes.zeroPageIndirect,
            Opcodes.zeroPageIndirectIndexed,
            Opcodes.zeroPageThenRelative,
            Opcodes.unused1,
            Opcodes.unused2,
            Opcodes.unused3
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

        XCTAssert(try testOpcode(Opcodes.accumulator.first!, expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.implied.first!, expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.stack.first!, expectedSize: 1))
        XCTAssert(try testOpcode(Opcodes.immediate.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.absolute.first!, expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.absoluteIndexedX.first!, expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.absoluteIndexedY.first!, expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.absoluteIndirect.first!, expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.absoluteIndexedIndirect.first!, expectedSize: 3))
        XCTAssert(try testOpcode(Opcodes.zeroPage.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageIndexedX.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageIndexedY.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageIndirect.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageIndexedIndirect.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageIndirectIndexed.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.relative.first!, expectedSize: 2))
        XCTAssert(try testOpcode(Opcodes.zeroPageThenRelative.first!, expectedSize: 3))
    }

    func testImplied() throws {
        for opcode in Opcodes.implied {
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .implied)
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
            XCTAssertThrowsError(try addressingMode.address(from: ram, registers: mpu.registers))
        }
    }

    func testAccumulator() throws {
        for opcode in Opcodes.accumulator {
            mpu.registers.A = 0x18
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .accumulator)
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == 0x18)
            XCTAssertThrowsError(try addressingMode.address(from: ram, registers: mpu.registers))
        }
    }

    func testStack() throws {
        for opcode in Opcodes.stack {
            try ram.write(to: mpu.registers.PC, data: opcode)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .stack)
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
            XCTAssertThrowsError(try addressingMode.address(from: ram, registers: mpu.registers))
        }
    }

    func testImmediate() throws {
        let immediateOpcodes = Opcodes.immediate

        for opcode in immediateOpcodes {
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: opcode &+ 1)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .immediate(value: opcode &+ 1))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)

            // doesn't support word mode
            XCTAssertThrowsError(try addressingMode.address(from: ram, registers: mpu.registers))
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
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == adjustedAddress)
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }
    }

    func testAbsoluteIndex() throws {
        let absolutePageBase: UInt16 = 0x6000

        func testAbsoluteIndexedOpcode(_ opcode: UInt8, atIndex index: UInt8, registerIsX: Bool) throws {
            try ram.write(to: absolutePageBase + UInt16(index), data: opcode &+ 1)
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(toAddressStartingAt: mpu.registers.PC + 1, word: absolutePageBase)

            if registerIsX {
                mpu.registers.X = index
            } else {
                mpu.registers.Y = index
            }

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .absoluteIndexed(address: absolutePageBase, offset: index))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == absolutePageBase + UInt16(index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }

        for (index, opcode) in Opcodes.absoluteIndexedX.enumerated() {
            try testAbsoluteIndexedOpcode(opcode, atIndex: UInt8(index), registerIsX: true)
        }

        for (index, opcode) in Opcodes.absoluteIndexedY.enumerated() {
            try testAbsoluteIndexedOpcode(opcode, atIndex: UInt8(index), registerIsX: false)
        }
    }

    func testAbsoluteIndirect() throws {
        let indirectBase: UInt16 = 0x3456

        // there's really only one but let's just follow convention blindly, shall we?
        for opcode in Opcodes.absoluteIndirect {
            try ram.write(toAddressStartingAt: indirectBase, word: UInt16(opcode &+ 1))

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(toAddressStartingAt: mpu.registers.PC + 1, word: indirectBase)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .absoluteIndirect(address: indirectBase))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == UInt16(opcode &+ 1))

            // doesn't support value mode
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
        }
    }

    func testAbsoluteIndexedIndirect() throws {
        let indirectBase: UInt16 = 0xDEAD
        let resolvedBase: UInt16 = 0x0BAE

        for (index, opcode) in Opcodes.absoluteIndexedIndirect.enumerated() {
            // there's only one opcode so let's inject a value for index here
            let synthesizedIndex = UInt8(index + 2)
            try ram.write(toAddressStartingAt: indirectBase + UInt16(synthesizedIndex), word: resolvedBase)

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(toAddressStartingAt: mpu.registers.PC + 1, word: indirectBase)
            mpu.registers.X = synthesizedIndex

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .absoluteIndexedIndirect(address: indirectBase, offset: synthesizedIndex))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == resolvedBase)

            // doesn't support value mode
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
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
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == resolvedAddress)

            // doesn't support value mode
            XCTAssertThrowsError(try addressingMode.value(from: ram, registers: mpu.registers))
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
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == UInt16(index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }
    }

    func testZeroPagedIndexed() throws {
        let zeroPageBase: UInt8 = 0x80

        func testZeroPagedIndexedOpcode(_ opcode: UInt8, atIndex index: UInt8, registerIsX: Bool) throws {
            try ram.write(to: UInt16(zeroPageBase + index), data: opcode &+ 1)
            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: zeroPageBase)

            if registerIsX {
                mpu.registers.X = index
            } else {
                mpu.registers.Y = index
            }

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPageIndexed(address: zeroPageBase, offset: index))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == UInt16(zeroPageBase + index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }

        for (index, opcode) in Opcodes.zeroPageIndexedX.enumerated() {
            try testZeroPagedIndexedOpcode(opcode, atIndex: UInt8(index), registerIsX: true)
        }

        for (index, opcode) in Opcodes.zeroPageIndexedY.enumerated() {
            try testZeroPagedIndexedOpcode(opcode, atIndex: UInt8(index), registerIsX: false)
        }

        // test wraparound
        mpu.registers.X = 0x81
        try ram.write(to: UInt16(zeroPageBase &+ mpu.registers.X), data: 0xAA)
        try ram.write(to: mpu.registers.PC, data: Opcodes.zeroPageIndexedX.first!)
        try ram.write(to: mpu.registers.PC + 1, data: zeroPageBase)

        let addressingMode = try mpu.fetch().addressingMode
        XCTAssert(addressingMode ~= .zeroPageIndexed(address: zeroPageBase, offset: 0x81))
        XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == 0xAA)
        XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == 0x01)
    }

    func testZeroPageIndirect() throws {
        let indirectBase: UInt16 = 0x0666

        for (index, opcode) in Opcodes.zeroPageIndirect.enumerated() {
            // write the eventual value
            try ram.write(to: indirectBase + UInt16(index), data: opcode &+ 1)

            // write resolved addr to zero page address
            try ram.write(toAddressStartingAt: UInt16(index * 2), word: indirectBase + UInt16(index))

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: UInt8(index * 2))

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPageIndirect(address: UInt8(index * 2)))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == indirectBase + UInt16(index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }
    }

    func testZeroPageIndexedIndirect() throws {
        let zeroPageBase: UInt8 = 0xA0
        let resolvedBase: UInt16 = 0xB00F

        for (index, opcode) in Opcodes.zeroPageIndexedIndirect.enumerated() {
            try ram.write(to: resolvedBase + UInt16(index), data: opcode &+ 1)
            try ram.write(toAddressStartingAt: UInt16(zeroPageBase) + UInt16(index), word: resolvedBase + UInt16(index))

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: zeroPageBase)
            mpu.registers.X = UInt8(index)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPageIndexedIndirect(address: zeroPageBase, offset: UInt8(index)))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == resolvedBase + UInt16(index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }
    }

    func testZeroPageIndirectIndexed() throws {
        let zeroPageBase: UInt8 = 0xDA
        let resolvedBase: UInt16 = 0x1234

        for (index, opcode) in Opcodes.zeroPageIndirectIndexed.enumerated() {
            try ram.write(to: resolvedBase + UInt16(index), data: opcode &+ 1)
            try ram.write(toAddressStartingAt: UInt16(zeroPageBase), word: resolvedBase)

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: zeroPageBase)
            mpu.registers.Y = UInt8(index)

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPageIndirectIndexed(address: zeroPageBase, offset: UInt8(index)))
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == resolvedBase + UInt16(index))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)
        }
    }

    func testZeroPageThenRelative() throws {
        let negativeOffset = Int8(-120)
        let positiveOffset = Int8(120)

        for (index, opcode) in Opcodes.zeroPageThenRelative.enumerated() {
            let offset = index % 2 == 0 ? positiveOffset : negativeOffset

            try ram.write(to: UInt16(index), data: opcode &+ 1)

            try ram.write(to: mpu.registers.PC, data: opcode)
            try ram.write(to: mpu.registers.PC + 1, data: UInt8(index))
            try ram.write(to: mpu.registers.PC + 2, data: UInt8(bitPattern: offset))

            let addressingMode = try mpu.fetch().addressingMode
            XCTAssert(addressingMode ~= .zeroPageThenRelative(zeroPage: UInt8(index), relative: offset))
            XCTAssert(try addressingMode.value(from: ram, registers: mpu.registers) == opcode &+ 1)

            let relativeAddress = UInt16(bitPattern: Int16(offset)) &+ mpu.registers.PC
            XCTAssert(try addressingMode.address(from: ram, registers: mpu.registers) == relativeAddress)
        }
    }
}
