import XCTest
@testable import Microprocessed

final class LDATests: SystemTests {

    func testLDAImmediate() throws {
        let opcode: UInt8 = 0xA9
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.A == opcode)
    }

    func testLDAZeroPage() throws {
        let opcode: UInt8 = 0xA5
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.A == opcode)
    }

    func testLDAZeroPageIndexed() throws {
        let opcode: UInt8 = 0xB5
        mpu.registers.X = 0x04
        try ram.write(to: 0x0080 + UInt16(mpu.registers.X), data: opcode &+ 1)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAAbsolute() throws {
        let opcode: UInt8 = 0xAD
        try ram.write(to: 0xC999, data: opcode &+ 1)

        try mpu.execute(opcode, word: 0xC999)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0xBD
        mpu.registers.X = 0x11
        try ram.write(to: 0x8990 + UInt16(mpu.registers.X), data: opcode &+ 1)

        try mpu.execute(opcode, word: 0x8990)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0xB9
        mpu.registers.Y = 0x40
        try ram.write(to: 0xAFF1 + UInt16(mpu.registers.Y), data: opcode &+ 1)

        try mpu.execute(opcode, word: 0xAFF1)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0xA1
        let resolvedAddress: UInt16 = 0x3001

        mpu.registers.X = 0x58
        try ram.write(to: resolvedAddress, data: opcode &+ 1)
        try ram.write(toAddressStartingAt: 0x90 + UInt16(mpu.registers.X), word: resolvedAddress)

        try mpu.execute(opcode, data: 0x90)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0xB1
        let baseAddress: UInt16 = 0x9020

        mpu.registers.Y = 0x01
        try ram.write(to: baseAddress + UInt16(mpu.registers.Y), data: opcode &+ 1)
        try ram.write(toAddressStartingAt: 0x22, word: baseAddress)

        try mpu.execute(opcode, data: 0x22)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }

    func testLDAZeroPageIndirect() throws {
        let opcode: UInt8 = 0xB2
        let indirectAddress: UInt16 = 0x1071

        try ram.write(to: indirectAddress, data: opcode &+ 1)
        try ram.write(toAddressStartingAt: 0x89, word: indirectAddress)

        try mpu.execute(opcode, data: 0x89)
        XCTAssert(mpu.registers.A == opcode &+ 1)
    }
}
