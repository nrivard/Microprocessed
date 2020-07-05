import XCTest
@testable import Microprocessed

final class TYATests: SystemTests {

    func testTYA() throws {
        let opcode: UInt8 = 0x98
        mpu.registers.Y = 0xF5

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == mpu.registers.A)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
