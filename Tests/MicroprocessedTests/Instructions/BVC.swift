import XCTest
@testable import Microprocessed

final class BVCTests: SystemTests {

    func testBVC() throws {
        try runBranchTest(opcode: 0x50, notTakenCondition: mpu.registers.setOverflow(), takenCondition: mpu.registers.clearOverflow())
    }
}
