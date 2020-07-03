import XCTest
@testable import Microprocessed

final class BEQTests: SystemTests {

    func testBEQ() throws {
        let opcode: UInt8 = 0xF0
        try runBranchTest(opcode: opcode, notTakenCondition: mpu.registers.clearZero(), takenCondition: mpu.registers.setZero())
    }
}
