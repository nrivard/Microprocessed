import XCTest
@testable import Microprocessed

final class ROLTests: SystemTests {

    static let startValue: UInt8 = 0b0101_0101
    static let endValue: UInt8 = 0b1010_1010

    func testROLAccumulator() throws {
        let opcode: UInt8 = 0x2A
        mpu.registers.A = ROLTests.startValue

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == ROLTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.A == ROLTests.startValue)
        assertStartStatusFlags()
    }

    func testROLZeroPage() throws {
        let opcode: UInt8 = 0x26
        try ram.write(to: 0x003F, data: ROLTests.startValue)

        try mpu.execute(opcode, data: 0x3F)
        XCTAssert(try ram.read(from: 0x003F) == ROLTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, data: 0x3F)
        XCTAssert(try ram.read(from: 0x003F) == ROLTests.startValue)
        assertStartStatusFlags()
    }

    func testROLZeroPageIndexed() throws {
        let opcode: UInt8 = 0x36
        mpu.registers.X = 0x03
        try ram.write(to: 0x001A, data: ROLTests.startValue)

        try mpu.execute(opcode, data: 0x17)
        XCTAssert(try ram.read(from: 0x001A) == ROLTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, data: 0x17)
        XCTAssert(try ram.read(from: 0x001A) == ROLTests.startValue)
        assertStartStatusFlags()
    }

    func testROLAbsolute() throws {
        let opcode: UInt8 = 0x2E
        let address: UInt16 = 0x5005
        try ram.write(to: address, data: ROLTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == ROLTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: address) == ROLTests.startValue)
        assertStartStatusFlags()
    }

    func testROLAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x3E
        let address: UInt16 = 0x6000
        mpu.registers.X = 0x06
        let finalAddress: UInt16 = address + UInt16(mpu.registers.X)
        try ram.write(to: finalAddress, data: ROLTests.startValue)

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: finalAddress) == ROLTests.endValue)
        assertEndStatusFlags()

        mpu.registers.setCarry()

        try mpu.execute(opcode, word: address)
        XCTAssert(try ram.read(from: finalAddress) == ROLTests.startValue)
        assertStartStatusFlags()
    }
}

extension ROLTests {

    private func assertEndStatusFlags() {
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))
    }

    private func assertStartStatusFlags() {
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }
}
