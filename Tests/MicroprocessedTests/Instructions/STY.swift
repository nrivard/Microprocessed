import XCTest
@testable import Microprocessed

final class STYTests: SystemTests {

    func testSTYZeroPage() throws {
        let opcode: UInt8 = 0x84
        mpu.registers.Y = opcode &+ 1

        try mpu.execute(opcode, data: 0xD0)
        XCTAssert(try ram.read(from: 0x00D0) == mpu.registers.Y)
    }

    func testSTYZeroPageIndexed() throws {
        let opcode: UInt8 = 0x94
        mpu.registers.Y = opcode &+ 1
        mpu.registers.X = 0x05

        try mpu.execute(opcode, data: 0x90)
        XCTAssert(try ram.read(from: 0x0095) == mpu.registers.Y)
    }

    func testSTXAbsolute() throws {
        let opcode: UInt8 = 0x8C
        mpu.registers.Y = opcode &+ 1

        try mpu.execute(opcode, word: 0xC3B0)
        XCTAssert(try ram.read(from: 0xC3B0) == mpu.registers.Y)
    }
}
