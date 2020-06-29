import XCTest
@testable import Microprocessed

final class INATests: SystemTests {

    func testINA() throws {
        let opcode: UInt8 = 0x1A
        mpu.registers.A = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0xD5)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))

        mpu.registers.A = 0xFF

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0x00)
        XCTAssert(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
    }
}
