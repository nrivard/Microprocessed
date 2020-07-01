import XCTest
@testable import Microprocessed

final class RTSTests: SystemTests {

    func testJSR() throws {
        let opcode: UInt8 = 0x60
        let returnAddress: UInt16 = 0xA5DF
        try mpu.pushWord(returnAddress - 1)

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.PC == returnAddress)
    }
}
