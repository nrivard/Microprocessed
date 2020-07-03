import XCTest
@testable import Microprocessed

final class BVSTests: SystemTests {

    func testBVS() throws {
        try runBranchTest(opcode: 0x70, notTakenCondition: mpu.registers.clearOverflow(), takenCondition: mpu.registers.setOverflow())
    }
}
