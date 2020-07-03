import XCTest
@testable import Microprocessed

final class BPLTests: SystemTests {

    func testBPL() throws {
        let opcode: UInt8 = 0x10
        try runBranchTest(opcode: opcode, notTakenCondition: mpu.registers.setIsNegative(), takenCondition: mpu.registers.clearIsNegative())
    }
}
