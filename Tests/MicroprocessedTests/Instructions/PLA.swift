import XCTest
@testable import Microprocessed

final class PLATests: SystemTests {

    func testPLA() throws {
        let opcode: UInt8 = 0x68
        try mpu.push(0x31)
        let sp = mpu.registers.$SP

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0x31)
        XCTAssert(mpu.registers.$SP == sp + 1)
    }
}
