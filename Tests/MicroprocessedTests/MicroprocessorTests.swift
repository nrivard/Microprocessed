import XCTest
@testable import Microprocessed

final class MicroprocessorTests: SystemTests {

    func testFetch() throws {
        try ram.writeWord(toAddressStartingAt: Microprocessor.resetVectorLow, word: 0x8000)

        try mpu.reset()
        XCTAssert(mpu.registers.PC == 0x8000)

        let instruction = try mpu.fetch()
        XCTAssert(mpu.registers.PC == 0x8001)
        XCTAssert(instruction.mnemonic ~= .nop)
    }
}
