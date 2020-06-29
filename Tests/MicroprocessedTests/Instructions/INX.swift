import XCTest
@testable import Microprocessed

final class INXTests: SystemTests {

    func testINX() throws {
        let opcode: UInt8 = 0xE8
        mpu.registers.X = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0xD5)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
