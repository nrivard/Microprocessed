import XCTest
@testable import Microprocessed

final class PLPTests: SystemTests {

    func testPLP() throws {
        let opcode: UInt8 = 0x28
        try mpu.push(0b10101010)
        let sp = mpu.registers.$SP

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.SR == 0b10111010) // 4 and 5 are _always_ set in the actual MPU
        XCTAssert(mpu.registers.$SP == sp + 1)
    }
}
