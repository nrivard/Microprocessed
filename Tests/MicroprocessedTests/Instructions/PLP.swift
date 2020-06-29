import XCTest
@testable import Microprocessed

final class PLPTests: SystemTests {

    func testPLP() throws {
        let opcode: UInt8 = 0x28
        try mpu.push(0b10101010)
        let sp = mpu.stackPointerAddress

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.SR == 0b10101010)
        XCTAssert(mpu.stackPointerAddress == sp + 1)
    }
}
