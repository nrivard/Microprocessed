import XCTest
@testable import Microprocessed


final class NOPTests: SystemTests {

    func testNOP() throws {
        let pc = mpu.registers.PC

        let opcode: UInt8 = Instruction.Mnemonic.Opcodes.noop[0]
        try mpu.execute(opcode)

        XCTAssert(mpu.registers.PC == pc + 1)
    }
}
