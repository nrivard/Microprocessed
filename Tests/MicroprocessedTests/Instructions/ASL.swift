import XCTest
@testable import Microprocessed

final class ASLTests: SystemTests {

    static let startValue: UInt8 = 0b0101_0101
    static let nextValue: UInt8 = 0b1010_1010
    static let endValue: UInt8 = 0b0101_0100

    func testASLAccumulator() throws {
        let opcode: UInt8 = 0x0A
        mpu.registers.A = ASLTests.startValue

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == ASLTests.nextValue)
        assertNextStatusFlags()

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == ASLTests.endValue)
        assertEndStatusFlags()
    }

    func testASLZeroPage() throws {
        let opcode: UInt8 = 0x06
        try ram.write(to: 0x0020, data: ASLTests.startValue)

        try mpu.execute(opcode, data: 0x20)
        XCTAssert(try ram.read(from: 0x0020) == ASLTests.nextValue)
        assertNextStatusFlags()

        try mpu.execute(opcode, data: 0x20)
        XCTAssert(try ram.read(from: 0x0020) == ASLTests.endValue)
        assertEndStatusFlags()
    }

    func testASLZeroPageIndexed() throws {
        let opcode: UInt8 = 0x16
        mpu.registers.X = 0x10
        try ram.write(to: 0x0020, data: ASLTests.startValue)

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0020) == ASLTests.nextValue)
        assertNextStatusFlags()

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0020) == ASLTests.endValue)
        assertEndStatusFlags()
    }

    func testASLAbsolute() throws {
        let opcode: UInt8 = 0x0E
        let address: UInt16 = 0x1190
        try ram.write(to: address, data: ASLTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == ASLTests.nextValue)
        assertNextStatusFlags()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == ASLTests.endValue)
        assertEndStatusFlags()
    }

    func testASLAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x1E
        let address: UInt16 = 0x1190
        mpu.registers.X = 0x10
        try ram.write(to: 0x11A0, data: ASLTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address + 0x10) == ASLTests.nextValue)
        assertNextStatusFlags()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address + 0x10) == ASLTests.endValue)
        assertEndStatusFlags()
    }
}

extension ASLTests {

    private func assertNextStatusFlags() {
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))
    }

    private func assertEndStatusFlags() {
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }
}
