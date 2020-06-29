import XCTest
@testable import Microprocessed


final class NOPTests: SystemTests {

    func testNOP() throws {
        let previousRegisters = mpu.registers

        let opcode: UInt8 = Instruction.Mnemonic.Opcodes.noop[0]
        try ram.write(to: mpu.registers.PC, data: opcode)

        try mpu.tick()
        // TODO: verify registers are exactly the same _except_ for PC which should be PC + 1
    }
}
