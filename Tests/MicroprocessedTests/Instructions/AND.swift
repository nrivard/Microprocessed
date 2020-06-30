import XCTest
@testable import Microprocessed

final class ANDTests: SystemTests {

    static let startValue: UInt8 = 0b1010_1010
    static let compareValue: UInt8 = 0b1000_1111
    static let resultValue: UInt8 = 0b1000_1010

    override func setUpWithError() throws {
        try super.setUpWithError()

        mpu.registers.A = ANDTests.startValue
    }

    func testANDImmediate() throws {
        let opcode: UInt8 = 0x29
        try mpu.execute(opcode, data: ANDTests.compareValue)
        assertValueAndFlags()
    }

    func testANDZeroPage() throws {
        let opcode: UInt8 = 0x25
        try ram.write(to: 0x0025, data: ANDTests.compareValue)

        try mpu.execute(opcode, data: 0x25)
        assertValueAndFlags()
    }

    func testANDZeroPageIndexed() throws {
        let opcode: UInt8 = 0x35
        mpu.registers.X = 0x05
        try ram.write(to: 0x0015, data: ANDTests.compareValue)

        try mpu.execute(opcode, data: 0x10)
        assertValueAndFlags()
    }

    func testANDAbsolute() throws {
        let opcode: UInt8 = 0x2D
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ANDTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testANDAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0x3D
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.X = 0x0F
        try ram.write(to: finalAddress, data: ANDTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testANDAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0x39
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.Y = 0x0F
        try ram.write(to: finalAddress, data: ANDTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testANDZeroPageIndirect() throws {
        let opcode: UInt8 = 0x32
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ANDTests.compareValue)
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }

    func testANDZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0x21
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ANDTests.compareValue)

        mpu.registers.X = 0x05
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x50)
        assertValueAndFlags()
    }

    func testANDZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0x31
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        try ram.write(to: finalAddress, data: ANDTests.compareValue)

        mpu.registers.Y = 0x0F
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }
}

extension ANDTests {

    private func assertValueAndFlags() {
        XCTAssert(mpu.registers.A == ANDTests.resultValue)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
