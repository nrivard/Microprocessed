import XCTest
@testable import Microprocessed

final class DEATests: SystemTests {

    func testDEA() throws {
        let opcode: UInt8 = 0x3A
        mpu.registers.A = 0xD4

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0xD3)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))

        mpu.registers.A = 0x00
        
        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == 0xFF)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
