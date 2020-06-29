import XCTest
@testable import Microprocessed

final class STATests: SystemTests {

    func testSTAZeroPage() throws {
        let opcode: UInt8 = 0x85
        mpu.registers.A = opcode &+ 1

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0010) == mpu.registers.A)
    }

    func testSTAZeroPageIndexed() throws {
        let opcode: UInt8 = 0x95
        mpu.registers.A = opcode &+ 1
        mpu.registers.X = 0x05

        try mpu.execute(opcode, data: 0x90)
        XCTAssert(try ram.read(from: 0x0095) == mpu.registers.A)
    }

    func testSTAAbsolute() throws {
        let opcode: UInt8 = 0x8D
        mpu.registers.A = opcode &+ 1

        try mpu.execute(opcode, word: 0xC3B0)
        XCTAssert(try ram.read(from: 0xC3B0) == mpu.registers.A)
    }

    func testSTAAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0x9D
        mpu.registers.A = opcode &+ 1
        mpu.registers.X = 0x03

        try mpu.execute(opcode, word: 0x1002)
        XCTAssert(try ram.read(from: 0x1005) == mpu.registers.A)
    }

    func testSTAAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0x99
        mpu.registers.A = opcode &+ 1
        mpu.registers.Y = 0x03

        try mpu.execute(opcode, word: 0x1002)
        XCTAssert(try ram.read(from: 0x1005) == mpu.registers.A)
    }

    func testSTAZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0x81
        let resolvedAddress: UInt16 = 0xB000

        mpu.registers.A = opcode &+ 1
        mpu.registers.X = 0x07
        try ram.write(toAddressStartingAt: 0x0027, word: resolvedAddress)

        try mpu.execute(opcode, data: 0x20)
        XCTAssert(try ram.read(from: resolvedAddress) == mpu.registers.A)
    }

    func testSTAZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0x91
        let resolvedAddress: UInt16 = 0xCA14

        mpu.registers.A = opcode &+ 1
        mpu.registers.Y = 0x11
        try ram.write(toAddressStartingAt: 0x0001, word: resolvedAddress)

        try mpu.execute(opcode, data: 0x01)
        XCTAssert(try ram.read(from: resolvedAddress + UInt16(0x11)) == mpu.registers.A)
    }

    func testSTAZeroPageIndirect() throws {
        let opcode: UInt8 = 0x92
        let resolvedAddress: UInt16 = 0x1103

        mpu.registers.A = opcode &+ 1
        try ram.write(toAddressStartingAt: 0x0079, word: resolvedAddress)

        try mpu.execute(opcode, data: 0x79)
        XCTAssert(try ram.read(from: resolvedAddress) == mpu.registers.A)
    }
}
