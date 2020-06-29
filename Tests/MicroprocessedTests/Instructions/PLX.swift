import XCTest
@testable import Microprocessed

final class PLXTests: SystemTests {

    func testPLX() throws {
        let opcode: UInt8 = 0xFA
        try mpu.push(0x31)
        let sp = mpu.stackPointerAddress

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0x31)
        XCTAssert(mpu.stackPointerAddress == sp + 1)
    }
}
