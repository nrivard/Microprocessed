import XCTest
@testable import Microprocessed

final class TXSTests: SystemTests {

    func testTXS() throws {
        let opcode: UInt8 = 0x9A
        mpu.registers.X = 0x02

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.SP == mpu.registers.X)
        XCTAssert(mpu.stackPointerAddress == Microprocessor.stackPointerBase + UInt16(mpu.registers.X))
    }
}
