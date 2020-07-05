import XCTest
@testable import Microprocessed

final class CLDTests: SystemTests {

    func testCLD() throws {
        let opcode: UInt8 = 0xD8

        mpu.registers.setDecimal()
        XCTAssert(mpu.registers.$SR.contains(.decimalMode))

        try mpu.execute(opcode)
        XCTAssertFalse(mpu.registers.$SR.contains(.decimalMode))
    }
}
