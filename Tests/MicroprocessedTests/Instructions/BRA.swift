import XCTest
@testable import Microprocessed

final class BRATests: SystemTests {

    func testBRA() throws {
        let originalPC = mpu.registers.PC
        let opcode: UInt8 = 0x80
        let offset: Int8 = 0x03
        try mpu.execute(opcode, data: UInt8(bitPattern: offset))

        let expectedPC = Int32(originalPC) + 2 + Int32(offset)
        XCTAssert(mpu.registers.PC == UInt16(expectedPC))
    }

    func testBRANegative() throws {
        let originalPC = mpu.registers.PC
        let opcode: UInt8 = 0x80
        let offset: Int8 = -0x05
        try mpu.execute(opcode, data: UInt8(bitPattern: offset))

        let expectedPC = Int32(originalPC) + 2 + Int32(offset)
        XCTAssert(mpu.registers.PC == UInt16(expectedPC))
    }
}
