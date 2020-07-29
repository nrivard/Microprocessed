import XCTest
@testable import Microprocessed

final class PHXTests: SystemTests {

    func testPHX() throws {
        let opcode: UInt8 = 0xDA
        let sp = mpu.registers.$SP
        mpu.registers.X = 0x99

        try mpu.execute(opcode)
        XCTAssert(try ram.read(from: sp) == mpu.registers.X)
        XCTAssert(mpu.registers.$SP == sp - 1)
    }
}
