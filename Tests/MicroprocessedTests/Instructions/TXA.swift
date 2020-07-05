import XCTest
@testable import Microprocessed

final class TXATests: SystemTests {

    func testTXA() throws {
        let opcode: UInt8 = 0x8A
        mpu.registers.X = 0xF5

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == mpu.registers.A)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
