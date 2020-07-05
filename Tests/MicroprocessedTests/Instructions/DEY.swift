import XCTest
@testable import Microprocessed

final class DEYTests: SystemTests {

    func testDEY() throws {
        let opcode: UInt8 = 0x88
        mpu.registers.Y = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == 0xD3)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        mpu.registers.Y = 0x00

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == 0xFF)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
