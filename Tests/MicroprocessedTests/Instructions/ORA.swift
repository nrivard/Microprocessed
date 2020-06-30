import XCTest
@testable import Microprocessed

final class ORATests: SystemTests {

    static let startValue: UInt8 = 0b1000_1000
    static let compareValue: UInt8 = 0b0010_0010
    static let resultValue: UInt8 = 0b1010_1010

    override func setUpWithError() throws {
        try super.setUpWithError()

        mpu.registers.A = ORATests.startValue
    }

    func testORAImmediate() throws {
        let opcode: UInt8 = 0x09
        try mpu.execute(opcode, data: ORATests.compareValue)
        assertValueAndFlags()
    }

    func testORAZeroPage() throws {
        let opcode: UInt8 = 0x05
        try ram.write(to: 0x0025, data: ORATests.compareValue)

        try mpu.execute(opcode, data: 0x25)
        assertValueAndFlags()
    }

    func testORAZeroPageIndexed() throws {
        let opcode: UInt8 = 0x15
        mpu.registers.X = 0x05
        try ram.write(to: 0x0015, data: ORATests.compareValue)

        try mpu.execute(opcode, data: 0x10)
        assertValueAndFlags()
    }

    func testORAAbsolute() throws {
        let opcode: UInt8 = 0x0D
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ORATests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0x1D
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.X = 0x0F
        try ram.write(to: finalAddress, data: ORATests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0x19
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.Y = 0x0F
        try ram.write(to: finalAddress, data: ORATests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAZeroPageIndirect() throws {
        let opcode: UInt8 = 0x12
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ORATests.compareValue)
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }

    func testORAZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0x01
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: ORATests.compareValue)

        mpu.registers.X = 0x05
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x50)
        assertValueAndFlags()
    }

    func testORAZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0x11
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        try ram.write(to: finalAddress, data: ORATests.compareValue)

        mpu.registers.Y = 0x0F
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }
}

extension ORATests {

    private func assertValueAndFlags() {
        XCTAssert(mpu.registers.A == ORATests.resultValue)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
