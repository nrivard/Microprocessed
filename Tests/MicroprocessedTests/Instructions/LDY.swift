import XCTest
@testable import Microprocessed

final class LDYTests: SystemTests {

    func testLDYImmediate() throws {
        let opcode: UInt8 = 0xA0
        try mpu.execute(opcode, data: opcode)
        XCTAssert(mpu.registers.Y == opcode)
    }

    func testLDYZeroPage() throws {
        let opcode: UInt8 = 0xA4
        try ram.write(to: 0x0080, data: opcode)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.Y == opcode)
    }

    func testLDYZeroPageIndexed() throws {
        let opcode: UInt8 = 0xB4
        mpu.registers.X = 0x07
        try ram.write(to: 0x0080 + UInt16(mpu.registers.X), data: opcode &+ 1)

        try mpu.execute(opcode, data: 0x80)
        XCTAssert(mpu.registers.Y == opcode &+ 1)
    }

    func testLDYAbsolute() throws {
        let opcode: UInt8 = 0xAC
        try ram.write(to: 0x0101, data: opcode &+ 1)

        try mpu.execute(opcode, word: 0x0101)
        XCTAssert(mpu.registers.Y == opcode &+ 1)
    }

    func testLDYAbsoluteIndexed() throws {
        let opcode: UInt8 = 0xBC
        mpu.registers.X = 0x76
        try ram.write(to: 0x5543 + UInt16(mpu.registers.X), data: opcode &+ 1)

        try mpu.execute(opcode, word: 0x5543)
        XCTAssert(mpu.registers.Y == opcode &+ 1)
    }
}
