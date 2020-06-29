import XCTest
@testable import Microprocessed

final class DEXTests: SystemTests {

    func testDEX() throws {
        let opcode: UInt8 = 0xCA
        mpu.registers.X = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0xD3)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
