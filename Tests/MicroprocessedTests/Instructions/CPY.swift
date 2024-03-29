import XCTest
@testable import Microprocessed

final class CPYTests: SystemTests {

    func testCPYImmediate() throws {
        let opcode: UInt8 = 0xC0
        mpu.registers.Y = 0xA0

        try mpu.execute(opcode, data: 0xA0)
        XCTAssert(mpu.registers.Y == 0xA0)
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }

    func testCPYZeroPage() throws {
        let opcode: UInt8 = 0xC4
        mpu.registers.Y = 0x80
        try ram.write(to: 0x0000, data: 0x8A)

        try mpu.execute(opcode, data: 0x00)
        XCTAssert(try ram.read(from: 0x00) == 0x8A) // memory untouched
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))
    }

    func testCPYAbsolute() throws {
        let opcode: UInt8 = 0xCC
        let address: UInt16 = 0xA5DF
        mpu.registers.Y = 0x80
        try ram.write(to: address, data: 0x01)

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }
}
