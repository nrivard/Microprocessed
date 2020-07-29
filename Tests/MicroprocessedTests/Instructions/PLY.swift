import XCTest
@testable import Microprocessed

final class PLYTests: SystemTests {

    func testPLY() throws {
        let opcode: UInt8 = 0x7A
        try mpu.push(0x31)
        let sp = mpu.registers.$SP

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.Y == 0x31)
        XCTAssert(mpu.registers.$SP == sp + 1)
    }
}
