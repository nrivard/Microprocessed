import XCTest
@testable import Microprocessed

final class JSRTests: SystemTests {

    func testJSR() throws {
        let opcode: UInt8 = 0x20
        let subroutineAddress: UInt16 = 0xA5DF

        /// we are going to execute a 3-byte instruction, so the stored PC value whould be (PC + 3) - 1
        let returnAddress = mpu.registers.PC + 2

        try mpu.execute(opcode, word: subroutineAddress)
        XCTAssert(mpu.registers.PC == subroutineAddress)
        XCTAssert(try mpu.popWord() == returnAddress)
    }
}
