import XCTest
@testable import Microprocessed

final class CLITests: SystemTests {

    func testCLI() throws {
        let opcode: UInt8 = 0x58

        mpu.registers.setInterruptsDisabled()
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))

        try mpu.execute(opcode)
        XCTAssertFalse(mpu.registers.statusFlags.contains(.interruptsDisabled))
    }
}
