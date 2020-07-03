import XCTest
@testable import Microprocessed

final class BMITests: SystemTests {

    func testBMI() throws {
        let opcode: UInt8 = 0x30
        try runBranchTest(opcode: opcode, notTakenCondition: mpu.registers.clearIsNegative(), takenCondition: mpu.registers.setIsNegative())
    }
}
