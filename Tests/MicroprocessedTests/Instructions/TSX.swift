import XCTest
@testable import Microprocessed

final class TSXTests: SystemTests {

    func testTSX() throws {
        let opcode: UInt8 = 0xBA
        mpu.registers.SP = 0xF5

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == mpu.registers.SP)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
