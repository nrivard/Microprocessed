import XCTest
@testable import Microprocessed

final class TAYTests: SystemTests {

    func testTAY() throws {
        let opcode: UInt8 = 0xA8
        mpu.registers.A = 0xF5

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == mpu.registers.A)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
