import XCTest
@testable import Microprocessed

final class STXTests: SystemTests {

    func testSTXZeroPage() throws {
        let opcode: UInt8 = 0x86
        mpu.registers.X = opcode &+ 1

        try mpu.execute(opcode, data: 0xD0)
        XCTAssert(try ram.read(from: 0x00D0) == mpu.registers.X)
    }

    func testSTXZeroPageIndexed() throws {
        let opcode: UInt8 = 0x96
        mpu.registers.X = opcode &+ 1
        mpu.registers.Y = 0x05

        try mpu.execute(opcode, data: 0x90)
        XCTAssert(try ram.read(from: 0x0095) == mpu.registers.X)
    }

    func testSTXAbsolute() throws {
        let opcode: UInt8 = 0x8E
        mpu.registers.X = opcode &+ 1

        try mpu.execute(opcode, word: 0xC3B0)
        XCTAssert(try ram.read(from: 0xC3B0) == mpu.registers.X)
    }
}
