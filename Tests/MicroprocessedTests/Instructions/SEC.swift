import XCTest
@testable import Microprocessed

final class SECTests: SystemTests {

    func testSEC() throws {
        let opcode: UInt8 = 0x38

        mpu.registers.clearCarry()
        XCTAssertFalse(mpu.registers.statusFlags.contains(.didCarry))

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
    }
}
