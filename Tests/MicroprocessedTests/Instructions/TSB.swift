import XCTest
@testable import Microprocessed

final class TSBTests: SystemTests {
    typealias DataSet = (input: UInt8, mask: UInt8, result: UInt8, zero: Bool)

    static let dataSet: [DataSet] = [
        (input: 0x80, mask: 0x01, result: 0x81, zero: true),
        (input: 0x00, mask: 0x00, result: 0x00, zero: true),
        (input: 0xAA, mask: 0x55, result: 0xFF, zero: true)
    ]

    func testTSBZeroPage() throws {
        let opcode: UInt8 = 0x04

        for (input, mask, result, zero) in TSBTests.dataSet {
            try ram.write(to: 0x2D, data: input)
            mpu.registers.A = mask

            try mpu.execute(opcode, data: 0x2D)
            XCTAssert(try ram.read(from: 0x2D) == result)
            XCTAssert(mpu.registers.$SR.contains(.isZero) == zero)
        }
    }

    func testTSBAbsolute() throws {
        let opcode: UInt8 = 0x0C

        for (input, mask, result, zero) in TSBTests.dataSet {
            try ram.write(to: 0xDDDD, data: input)
            mpu.registers.A = mask

            try mpu.execute(opcode, word: 0xDDDD)
            XCTAssert(try ram.read(from: 0xDDDD) == result)
            XCTAssert(mpu.registers.$SR.contains(.isZero) == zero)
        }
    }
}
