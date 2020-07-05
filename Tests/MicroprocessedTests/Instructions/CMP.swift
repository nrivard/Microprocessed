import XCTest
@testable import Microprocessed

final class CMPTests: SystemTests {

    func testCMPImmediate() throws {
        let opcode: UInt8 = 0xC9
        mpu.registers.A = 0xA0

        try mpu.execute(opcode, data: 0xA0)
        XCTAssert(mpu.registers.A == 0xA0)
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }

    func testCMPZeroPage() throws {
        let opcode: UInt8 = 0xC5
        mpu.registers.A = 0x80
        try ram.write(to: 0x0000, data: 0x8A)

        try mpu.execute(opcode, data: 0x00)
        XCTAssert(try ram.read(from: 0x00) == 0x8A) // memory untouched
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))
    }

    func testCMPZeroPageIndexed() throws {
        let opcode: UInt8 = 0xD5
        mpu.registers.A = 0xFF
        mpu.registers.X = 0x02
        try ram.write(to: 0x0002, data: 0x10)

        try mpu.execute(opcode, data: 0x00)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
    }

    func testCMPAbsolute() throws {
        let opcode: UInt8 = 0xCD
        let address: UInt16 = 0xA5DF
        mpu.registers.A = 0x80
        try ram.write(to: address, data: 0x01)

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }

    func testCMPAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0xDD
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.A = 0x10
        mpu.registers.X = 0x0F
        try ram.write(to: finalAddress, data: 0x10)

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }

    func testCMPAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0xD9
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.A = 0x10
        mpu.registers.Y = 0x0F
        try ram.write(to: finalAddress, data: 0x10)

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }

    func testCMPIndexedIndirect() throws {
        let opcode: UInt8 = 0xC1
        let address: UInt16 = 0xA5DF
        mpu.registers.A = 0x10
        mpu.registers.X = 0x05
        try ram.write(to: address, data: 0x10)
        try ram.write(toAddressStartingAt: 0x0005, word: address)

        try mpu.execute(opcode, data: 0x00)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }

    func testCMPIndirectIndexed() throws {
        let opcode: UInt8 = 0xD1
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = address + 0x05
        mpu.registers.A = 0x10
        mpu.registers.Y = 0x05
        try ram.write(to: finalAddress, data: 0x10)
        try ram.write(toAddressStartingAt: 0x30, word: address)

        try mpu.execute(opcode, data: 0x30)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }

    func testCMPZeroPageIndirect() throws {
        let opcode: UInt8 = 0xD2
        let address: UInt16 = 0xA5DF
        mpu.registers.A = 0x10
        try ram.write(to: address, data: 0x10)
        try ram.write(toAddressStartingAt: 0x0055, word: address)

        try mpu.execute(opcode, data: 0x55)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
    }
}
