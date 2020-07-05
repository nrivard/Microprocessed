import XCTest
@testable import Microprocessed

final class DECTests: SystemTests {

    func testDECZeroPage() throws {
        let opcode: UInt8 = 0xC6
        try ram.write(to: 0x0010, data: opcode)

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0010) == opcode &- 1)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))

        try ram.write(to: 0x011, data: 0x00)

        try mpu.execute(opcode, data: 0x11)
        XCTAssert(try ram.read(from: 0x0011)  == 0xFF)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }

    func testDECZeroPageIndexed() throws {
        let opcode: UInt8 = 0xD6
        try ram.write(to: 0x0013, data: opcode)
        mpu.registers.X = 0x03

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x013) == opcode &- 1)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }

    func testDECAbsolute() throws {
        let opcode: UInt8 = 0xCE
        try ram.write(to: 0xE0E0, data: opcode)

        try mpu.execute(opcode, word: 0xE0E0)
        XCTAssert(try ram.read(from: 0xE0E0) == opcode &- 1)

    }

    func testDECAbsoluteIndexed() throws {
        let opcode: UInt8 = 0xDE
        try ram.write(to: 0xF1FA, data: opcode)
        mpu.registers.X = 0x0A

        try mpu.execute(opcode, word: 0xF1F0)
        XCTAssert(try ram.read(from: 0xF1FA) == opcode &- 1)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }
}
