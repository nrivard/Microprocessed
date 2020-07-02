import XCTest
@testable import Microprocessed

final class BEQTests: SystemTests {

    func testBEQ() throws {
        let opcode: UInt8 = 0xF0
        let offset: Int8 = 0x03
        var originalPC = mpu.registers.PC

        // zero bit is _not_ set so don't branch
        try mpu.execute(opcode, data: UInt8(bitPattern: offset))
        XCTAssert(mpu.registers.PC == originalPC + 2)

        originalPC = mpu.registers.PC
        mpu.registers.setZero()

        try mpu.execute(opcode, data: UInt8(bitPattern: offset))
        let expectedPC = Int32(originalPC) + 2 + Int32(offset)
        XCTAssert(mpu.registers.PC == UInt16(expectedPC))
    }

    func testBEQNegative() throws {
        let opcode: UInt8 = 0xF0
        let offset: Int8 = -0x05
        var originalPC = mpu.registers.PC

        try mpu.execute(opcode, data: UInt8(bitPattern: offset))
        XCTAssert(mpu.registers.PC == originalPC + 2)

        originalPC = mpu.registers.PC
        mpu.registers.setZero()

        try mpu.execute(opcode, data: UInt8(bitPattern: offset))
        let expectedPC = Int32(originalPC) + 2 + Int32(offset)
        XCTAssert(mpu.registers.PC == UInt16(expectedPC))
    }
}
