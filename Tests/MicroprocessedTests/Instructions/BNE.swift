import XCTest
@testable import Microprocessed

final class BNETests: SystemTests {

    func testBNE() throws {
        let opcode: UInt8 = 0xD0
        try runBranchTest(opcode: opcode, notTakenCondition: mpu.registers.setZero(), takenCondition: mpu.registers.clearZero())
    }
}
