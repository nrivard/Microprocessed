import XCTest
@testable import Microprocessed

final class MicroprocessorTests: SystemTests {

    func testFetch() throws {
        XCTAssert(mpu.registers.PC == 0x8000)

        let instruction = try mpu.fetch()
        XCTAssert(mpu.registers.PC == 0x8001)
        XCTAssert(instruction.mnemonic ~= .nop)
        XCTAssert(instruction.size == 1)
    }

    func testUndefinedInstruction() throws {
        for opcode in Instruction.AddressingMode.Opcodes.unused {
            XCTAssertThrowsError(try mpu.execute(opcode, data: 0x00))
        }
    }

    func testLoadStatusFlags() throws {
        // uses all immediate address modes
        try mpu.testLoadImmediateStatusFlags(for: 0xA9)
        try mpu.testLoadImmediateStatusFlags(for: 0xA2)
        try mpu.testLoadImmediateStatusFlags(for: 0xA0)
    }
}

extension Microprocessor {

    /// convenience for executing an operandless opcode
    func execute(_ opcode: UInt8) throws {
        try memory.write(to: registers.PC, data: opcode)
        try tick()
    }

    /// convenience that writes an opcode and data, then executes it
    func execute(_ opcode: UInt8, data: UInt8) throws {
        try memory.write(to: registers.PC, data: opcode)
        try memory.write(to: registers.PC + 1, data: data)
        try tick()
    }

    /// convenience that writes an opcode and word, then executes it
    func execute(_ opcode: UInt8, word: UInt16) throws {
        try memory.write(to: registers.PC, data: opcode)
        try memory.write(toAddressStartingAt: registers.PC + 1, word: word)
        try tick()
    }

    func testLoadImmediateStatusFlags(for opcode: UInt8) throws {
        try execute(opcode, data: 0x00)
        XCTAssert(registers.statusFlags.contains(.isZero))
        XCTAssertFalse(registers.statusFlags.contains(.isNegative))

        try execute(opcode, data: 0x80)
        XCTAssertFalse(registers.statusFlags.contains(.isZero))
        XCTAssert(registers.statusFlags.contains(.isNegative))

        try execute(opcode, data: 0x70)
        XCTAssertFalse(registers.statusFlags.contains(.isZero))
        XCTAssertFalse(registers.statusFlags.contains(.isNegative))
    }
}
