import XCTest
@testable import Microprocessed

final class PHYTests: SystemTests {

    func testPHY() throws {
        let opcode: UInt8 = 0x5A
        let sp = mpu.stackPointerAddress
        mpu.registers.A = 0x99

        try mpu.execute(opcode)
        XCTAssert(try ram.read(from: sp) == mpu.registers.Y)
        XCTAssert(mpu.stackPointerAddress == sp - 1)
    }
}
