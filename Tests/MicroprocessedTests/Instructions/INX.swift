import XCTest
@testable import Microprocessed

final class INXTests: SystemTests {

    func testINX() throws {
        let opcode: UInt8 = 0xE8
        mpu.registers.X = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0xD5)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        mpu.registers.X = 0xFF

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0x00)
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }
}
