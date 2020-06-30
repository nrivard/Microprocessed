import XCTest
@testable import Microprocessed

final class EORTests: SystemTests {

    static let startValue: UInt8 = 0b1111_0000
    static let compareValue: UInt8 = 0b0101_1010
    static let resultValue: UInt8 = 0b1010_1010

    override func setUpWithError() throws {
        try super.setUpWithError()

        mpu.registers.A = EORTests.startValue
    }

    func testEORImmediate() throws {
        let opcode: UInt8 = 0x49
        try mpu.execute(opcode, data: EORTests.compareValue)
        assertValueAndFlags()
    }

    func testORAEORTestsZeroPage() throws {
        let opcode: UInt8 = 0x45
        try ram.write(to: 0x0025, data: EORTests.compareValue)

        try mpu.execute(opcode, data: 0x25)
        assertValueAndFlags()
    }

    func testORAEORTestsZeroPageIndexed() throws {
        let opcode: UInt8 = 0x55
        mpu.registers.X = 0x05
        try ram.write(to: 0x0015, data: EORTests.compareValue)

        try mpu.execute(opcode, data: 0x10)
        assertValueAndFlags()
    }

    func testORAEORTestsAbsolute() throws {
        let opcode: UInt8 = 0x4D
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: EORTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAEORTestsAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0x5D
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.X = 0x0F
        try ram.write(to: finalAddress, data: EORTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAEORTestsAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0x59
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.Y = 0x0F
        try ram.write(to: finalAddress, data: EORTests.compareValue)

        try mpu.execute(opcode, word: address)
        assertValueAndFlags()
    }

    func testORAEORTestsZeroPageIndirect() throws {
        let opcode: UInt8 = 0x52
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: EORTests.compareValue)
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }

    func testORAEORTestsZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0x41
        let address: UInt16 = 0xA5DF
        try ram.write(to: address, data: EORTests.compareValue)

        mpu.registers.X = 0x05
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x50)
        assertValueAndFlags()
    }

    func testORAEORTestsZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0x51
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        try ram.write(to: finalAddress, data: EORTests.compareValue)

        mpu.registers.Y = 0x0F
        try ram.write(toAddressStartingAt: 0x55, word: address)

        try mpu.execute(opcode, data: 0x55)
        assertValueAndFlags()
    }
}

extension EORTests {

    private func assertValueAndFlags() {
        XCTAssert(mpu.registers.A == EORTests.resultValue)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
    }
}
