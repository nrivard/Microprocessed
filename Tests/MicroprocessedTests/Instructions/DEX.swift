import XCTest
@testable import Microprocessed

final class DEXTests: SystemTests {

    func testDEX() throws {
        let opcode: UInt8 = 0xCA
        mpu.registers.X = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0xD3)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        mpu.registers.X = 0x00

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.X == 0xFF)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
