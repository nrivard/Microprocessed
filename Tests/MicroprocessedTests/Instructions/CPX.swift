import XCTest
@testable import Microprocessed

final class CPXTests: SystemTests {

    func testCPXImmediate() throws {
        let opcode: UInt8 = 0xE0
        mpu.registers.X = 0xA0

        try mpu.execute(opcode, data: 0xA0)
        XCTAssert(mpu.registers.X == 0xA0)
        XCTAssert(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
    }

    func testCPXZeroPage() throws {
        let opcode: UInt8 = 0xE4
        mpu.registers.X = 0x80
        try ram.write(to: 0x0000, data: 0x8A)

        try mpu.execute(opcode, data: 0x00)
        XCTAssert(try ram.read(from: 0x00) == 0x8A) // memory untouched
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.didCarry))
    }

    func testCPXAbsolute() throws {
        let opcode: UInt8 = 0xEC
        let address: UInt16 = 0xA5DF
        mpu.registers.X = 0x80
        try ram.write(to: address, data: 0x01)

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
    }
}
