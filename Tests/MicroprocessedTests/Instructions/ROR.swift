import XCTest
@testable import Microprocessed

final class RORTests: SystemTests {

    static let startValue: UInt8 = 0b1010_1010
    static let endValue: UInt8 = 0b0101_0101

    func testRORAccumulator() throws {
        let opcode: UInt8 = 0x6A
        mpu.registers.A = RORTests.startValue

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == RORTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == RORTests.startValue)
        assertStartStatusFlags()
    }

    func testRORZeroPage() throws {
        let opcode: UInt8 = 0x66
        try ram.write(to: 0x003F, data: RORTests.startValue)

        try mpu.execute(opcode, data: 0x3F)
        XCTAssert(try ram.read(from: 0x003F) == RORTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, data: 0x3F)
        XCTAssert(try ram.read(from: 0x003F) == RORTests.startValue)
        assertStartStatusFlags()
    }

    func testRORZeroPageIndexed() throws {
        let opcode: UInt8 = 0x76
        mpu.registers.X = 0x03
        try ram.write(to: 0x001A, data: RORTests.startValue)

        try mpu.execute(opcode, data: 0x17)
        XCTAssert(try ram.read(from: 0x001A) == RORTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, data: 0x17)
        XCTAssert(try ram.read(from: 0x001A) == RORTests.startValue)
        assertStartStatusFlags()
    }

    func testRORAbsolute() throws {
        let opcode: UInt8 = 0x6E
        let address: UInt16 = 0x5005
        try ram.write(to: address, data: RORTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == RORTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == RORTests.startValue)
        assertStartStatusFlags()
    }

    func testRORAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x7E
        let address: UInt16 = 0x6000
        mpu.registers.X = 0x06
        let finalAddress: UInt16 = address + UInt16(mpu.registers.X)
        try ram.write(to: finalAddress, data: RORTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: finalAddress) == RORTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: finalAddress) == RORTests.startValue)
        assertStartStatusFlags()
    }
}

extension RORTests {

    private func assertEndStatusFlags() {
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.didCarry))
    }

    private func assertStartStatusFlags() {
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
    }
}
