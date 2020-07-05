import XCTest
@testable import Microprocessed

final class BCSTests: SystemTests {

    func testBCS() throws {
        try runBranchTest(opcode: 0xB0, notTakenCondition: mpu.registers.clearCarry(), takenCondition: mpu.registers.setCarry())
    }
}
