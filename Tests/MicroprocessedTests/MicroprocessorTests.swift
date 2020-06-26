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

    // MARK: - LDA

    func testLDAImmediate() throws {
        let opcode: UInt8 = 0xA9
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: opcode)

        try mpu.tick()
        XCTAssert(mpu.registers.A == opcode)
    }

    func testLDAZeroPage() throws {
        let opcode: UInt8 = 0xA5
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: 0x80)
        try ram.write(to: 0x0080, data: opcode)

        try mpu.tick()
        XCTAssert(mpu.registers.A == opcode)
    }

    // MARK: - LDX

    func testLDXImmediate() throws {
        let opcode: UInt8 = 0xA2
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: opcode)

        try mpu.tick()
        XCTAssert(mpu.registers.X == opcode)
    }

    func testLDXZeroPage() throws {
        let opcode: UInt8 = 0xA6
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: 0x80)
        try ram.write(to: 0x0080, data: opcode)

        try mpu.tick()
        XCTAssert(mpu.registers.X == opcode)
    }

    // MARK: - LDY

    func testLDYImmediate() throws {
        let opcode: UInt8 = 0xA0
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: opcode)

        try mpu.tick()
        XCTAssert(mpu.registers.Y == opcode)
    }

    func testLDYZeroPage() throws {
        let opcode: UInt8 = 0xA4
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: 0x80)
        try ram.write(to: 0x0080, data: opcode)

        try mpu.tick()
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
