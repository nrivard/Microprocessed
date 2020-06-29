import XCTest
@testable import Microprocessed

final class LDXTests: SystemTests {

    func testLDXImmediate() throws {
        let opcode: UInt8 = 0xA2
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.X == opcode)
    }

    func testLDXZeroPage() throws {
        let opcode: UInt8 = 0xA6
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.X == opcode)
    }

    func testLDXZeroPageIndexed() throws {
        let opcode: UInt8 = 0xB6
        mpu.registers.Y = 0x15
        try ram.write(to: 0x0080 + UInt16(mpu.registers.Y), data: opcode &+ 1)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.X == opcode &+ 1)
    }

    func testLDXAbsolute() throws {
        let opcode: UInt8 = 0xAE
        try ram.write(to: 0x2002, data: opcode &+ 1)

        try mpu.execute(opcode, word: 0x2002)
        XCTAssert(mpu.registers.X == opcode &+ 1)
    }

    func testLDXAbsoluteIndexed() throws {
        let opcode: UInt8 = 0xBE
        mpu.registers.Y = 0xE1
        try ram.write(to: 0x1400 + UInt16(mpu.registers.Y), data: opcode &+ 1)

        try mpu.execute(opcode, word: 0x1400)
        XCTAssert(mpu.registers.X == opcode &+ 1)
    }
}
