import XCTest
@testable import Microprocessed


final class NOPTests: SystemTests {

    func testNOP() throws {
        let pc = mpu.registers.PC

        let opcode: UInt8 = Instruction.Mnemonic.Opcodes.nop.first!
        try mpu.execute(opcode)

        XCTAssert(mpu.registers.PC == pc + 1)
    }
}
