import XCTest
@testable import Microprocessed

final class BBRTests: SystemTests {

    func testBBR() throws {
        for (index, opcode) in Mnemonic.Opcodes.bbr.sorted().enumerated() {
            let mask: UInt8 = 1 << index

            try runBranchTest(opcode: opcode, notTakenCondition: {
                try ram.write(to: 0, data: mask)
            }(), takenCondition: {
                try ram.write(to: 0, data: 0)
            }())
        }
    }

    override func setupBranchTest(opcode: UInt8, offset: UInt8) throws {
        try ram.write(to: mpu.registers.PC, data: opcode)
        try ram.write(to: mpu.registers.PC + 1, data: 0)
        try ram.write(to: mpu.registers.PC + 2, data: offset)
    }
}
