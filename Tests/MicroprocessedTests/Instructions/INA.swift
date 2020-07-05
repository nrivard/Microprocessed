import XCTest
@testable import Microprocessed

final class INATests: SystemTests {

    func testINA() throws {
        let opcode: UInt8 = 0x1A
        mpu.registers.A = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0xD5)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        mpu.registers.A = 0xFF

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0x00)
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }
}
