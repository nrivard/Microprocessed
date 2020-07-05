import XCTest
@testable import Microprocessed

final class BCCTests: SystemTests {

    func testBCC() throws {
        try runBranchTest(opcode: 0x90, notTakenCondition: mpu.registers.setCarry(), takenCondition: mpu.registers.clearCarry())
    }
}
