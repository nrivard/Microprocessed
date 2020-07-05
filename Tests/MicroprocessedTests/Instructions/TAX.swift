import XCTest
@testable import Microprocessed

final class TAXTests: SystemTests {

    func testTAX() throws {
        let opcode: UInt8 = 0xAA
        mpu.registers.A = 0xF5

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == mpu.registers.A)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
