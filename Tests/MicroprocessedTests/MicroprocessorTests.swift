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

    // MARK: - LDA

    func testLDAImmediate() throws {
        let opcode: UInt8 = 0xA9
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.A == opcode)
    }

    func testLDAZeroPage() throws {
        let opcode: UInt8 = 0xA5
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.A == opcode)
    }

    // MARK: - LDX

    func testLDXImmediate() throws {
        let opcode: UInt8 = 0xA2
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.X == opcode)
    }

    func testLDXZeroPage() throws {
        let opcode: UInt8 = 0xA6
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.X == opcode)
    }

    // MARK: - LDY

    func testLDYImmediate() throws {
        let opcode: UInt8 = 0xA0
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.Y == opcode)
    }

    func testLDYZeroPage() throws {
        let opcode: UInt8 = 0xA4
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.Y == opcode)
    }

    // MARK: - NOP

    func testNOP() throws {
        let previousRegisters = mpu.registers

        let opcode: UInt8 = Instruction.Mnemonic.Opcodes.noop[0]
        try ram.write(to: mpu.registers.PC, data: opcode)

        try mpu.tick()
        // TODO: verify registers are exactly the same _except_ for PC which should be PC + 1
    }
}

extension Microprocessor {

    /// convenience that writes an opcode and data, then executes it
    func execute(_ opcode: UInt8, data: UInt8) throws {
        try memory.write(to: registers.PC, data: opcode)
        try memory.write(to: registers.PC + 1, data: data)
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
