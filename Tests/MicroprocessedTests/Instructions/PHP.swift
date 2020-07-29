import XCTest
@testable import Microprocessed

final class PHPTests: SystemTests {

    func testPHP() throws {
        let opcode: UInt8 = 0x08
        let sp = mpu.registers.$SP
        mpu.registers.SR = 0b10101010

        try mpu.execute(opcode)
        XCTAssert(try ram.read(from: sp) == mpu.registers.SR)
        XCTAssert(mpu.registers.$SP == sp - 1)
    }
}
