import XCTest
@testable import Microprocessed

final class LSRTests: SystemTests {

    static let startValue: UInt8 = 0b1010_1010
    static let nextValue: UInt8 = 0b0101_0101
    static let endValue: UInt8 = 0b0010_1010

    func testLSRAccumulator() throws {
        let opcode: UInt8 = 0x4A
        mpu.registers.A = LSRTests.startValue

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == LSRTests.nextValue)
        testNextStatusFlags()

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == LSRTests.endValue)
        testEndStatusFlags()
    }

    func testLSRZeroPage() throws {
        let opcode: UInt8 = 0x46
        try ram.write(to: 0x0020, data: LSRTests.startValue)

        try mpu.execute(opcode, data: 0x20)
        XCTAssert(try ram.read(from: 0x0020) == LSRTests.nextValue)
        testNextStatusFlags()

        try mpu.execute(opcode, data: 0x20)
        XCTAssert(try ram.read(from: 0x0020) == LSRTests.endValue)
        testEndStatusFlags()
    }

    func testLSRZeroPageIndexed() throws {
        let opcode: UInt8 = 0x56
        mpu.registers.X = 0x10
        try ram.write(to: 0x0020, data: LSRTests.startValue)

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0020) == LSRTests.nextValue)
        testNextStatusFlags()

        try mpu.execute(opcode, data: 0x10)
        XCTAssert(try ram.read(from: 0x0020) == LSRTests.endValue)
        testEndStatusFlags()
    }

    func testLSRAbsolute() throws {
        let opcode: UInt8 = 0x4E
        let address: UInt16 = 0x1190
        try ram.write(to: 0x1190, data: LSRTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == LSRTests.nextValue)
        testNextStatusFlags()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == LSRTests.endValue)
        testEndStatusFlags()
    }

    func testLSRAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x5E
        let address: UInt16 = 0x1190
        mpu.registers.X = 0x10
        try ram.write(to: 0x11A0, data: LSRTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address + 0x10) == LSRTests.nextValue)
        testNextStatusFlags()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address + 0x10) == LSRTests.endValue)
        testEndStatusFlags()
    }
}

extension LSRTests {

    private func testNextStatusFlags() {
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.didCarry))
    }

    private func testEndStatusFlags() {
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
    }
}
