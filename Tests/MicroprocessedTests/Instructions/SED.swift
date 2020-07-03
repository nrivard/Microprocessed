import XCTest
@testable import Microprocessed

final class SEDTests: SystemTests {

    func testSED() throws {
        let opcode: UInt8 = 0xF8

        mpu.registers.clearDecimal()
        XCTAssertFalse(mpu.registers.statusFlags.contains(.decimalMode))

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.statusFlags.contains(.decimalMode))
    }
}
