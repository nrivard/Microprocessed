import XCTest
@testable import Microprocessed

final class SECTests: SystemTests {

    func testSEC() throws {
        let opcode: UInt8 = 0x38

        mpu.registers.clearCarry()
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }
}
