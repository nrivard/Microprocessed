import XCTest
@testable import Microprocessed

final class PHATests: SystemTests {

    func testPHA() throws {
        let opcode: UInt8 = 0x48
        let sp = mpu.registers.$SP
        mpu.registers.A = 0x99

        try mpu.execute(opcode)
        XCTAssert(try ram.read(from: sp) == mpu.registers.A)
        XCTAssert(mpu.registers.$SP == sp - 1)
    }
}
