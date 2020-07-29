import XCTest
@testable import Microprocessed

final class PLXTests: SystemTests {

    func testPLX() throws {
        let opcode: UInt8 = 0xFA
        try mpu.push(0x31)
        let sp = mpu.registers.$SP

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0x31)
        XCTAssert(mpu.registers.$SP == sp + 1)
    }
}
