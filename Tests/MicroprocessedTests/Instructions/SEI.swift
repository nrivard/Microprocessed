import XCTest
@testable import Microprocessed

final class SEITests: SystemTests {

    func testSEI() throws {
        let opcode: UInt8 = 0x78

        mpu.registers.clearInterruptsDisabled()
        XCTAssertFalse(mpu.registers.$SR.contains(.interruptsDisabled))

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
    }
}
