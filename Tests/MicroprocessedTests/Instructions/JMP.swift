import XCTest
@testable import Microprocessed

final class JMPTests: SystemTests {

    func testJMPAbsolute() throws {
        let opcode: UInt8 = 0x4C
        let address: UInt16 = 0xA5DF

        try mpu.execute(opcode, word: address)
        XCTAssert(mpu.registers.PC == address)
    }

    func testJMPAbsoluteIndirect() throws {
        let opcode: UInt8 = 0x6C
        let pointer: UInt16 = 0xDEAD
        let address: UInt16 = 0xA5DF
        try ram.write(toAddressStartingAt: pointer, word: address)

        try mpu.execute(opcode, word: pointer)
        XCTAssert(mpu.registers.PC == address)
    }

    func testJMPAbsoluteIndexedIndirect() throws {
        let opcode: UInt8 = 0x7C
        let pointer: UInt16 = 0xDEA0
        let address: UInt16 = 0xA5DF
        mpu.registers.X = 0x0D
        try ram.write(toAddressStartingAt: 0xDEAD, word: address)

        try mpu.execute(opcode, word: pointer)
        XCTAssert(mpu.registers.PC == address)
    }
}
