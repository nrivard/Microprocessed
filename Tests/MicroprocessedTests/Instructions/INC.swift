import XCTest
@testable import Microprocessed

final class INCTests: SystemTests {

    func testINCZeroPage() throws {
        let opcode: UInt8 = 0xE6
        try ram.write(to: 0x0010, data: opcode)

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0010) == opcode &+ 1)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))

        try ram.write(to: 0x011, data: 0xFF)

        try mpu.execute(opcode, data: 0x11)
        XCTAssert(try ram.read(from: 0x0011)  == 0x00)
        XCTAssert(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
    }

    func testINCZeroPageIndexed() throws {
        let opcode: UInt8 = 0xF6
        try ram.write(to: 0x0013, data: opcode)
        mpu.registers.X = 0x03

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x013) == opcode &+ 1)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }

    func testINCAbsolute() throws {
        let opcode: UInt8 = 0xEE
        try ram.write(to: 0xE0E0, data: opcode)

        try mpu.execute(opcode, word: 0xE0E0)
        XCTAssert(try ram.read(from: 0xE0E0) == opcode &+ 1)

    }

    func testINCAbsoluteIndexed() throws {
        let opcode: UInt8 = 0xFE
        try ram.write(to: 0xF1FA, data: opcode)
        mpu.registers.X = 0x0A

        try mpu.execute(opcode, word: 0xF1F0)
        XCTAssert(try ram.read(from: 0xF1FA) == opcode &+ 1)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
