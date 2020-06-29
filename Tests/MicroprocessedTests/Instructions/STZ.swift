import XCTest
@testable import Microprocessed

final class STZTests: SystemTests {

    func testSTZZeroPage() throws {
        let opcode: UInt8 = 0x64

        try mpu.execute(opcode, data: 0xD0)
        XCTAssert(try ram.read(from: 0x00D0) == 0)
    }

    func testSTZZeroPageIndexed() throws {
        let opcode: UInt8 = 0x74
        mpu.registers.X = 0x05

        try mpu.execute(opcode, data: 0x90)
        XCTAssert(try ram.read(from: 0x0095) == 0)
    }

    func testSTZAbsolute() throws {
        let opcode: UInt8 = 0x9C

        try mpu.execute(opcode, word: 0xC3B0)
        XCTAssert(try ram.read(from: 0xC3B0) == 0)
    }

    func testSTZAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x9E
        mpu.registers.X = 0x03

        try mpu.execute(opcode, word: 0x1002)
        XCTAssert(try ram.read(from: 0x1005) == 0)
    }
}
