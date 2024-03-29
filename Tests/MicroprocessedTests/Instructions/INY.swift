import XCTest
@testable import Microprocessed

final class INYTests: SystemTests {

    func testINY() throws {
        let opcode: UInt8 = 0xC8
        mpu.registers.Y = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == 0xD5)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        mpu.registers.Y = 0xFF

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == 0x00)
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }
}
