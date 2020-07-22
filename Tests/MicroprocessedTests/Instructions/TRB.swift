import XCTest
@testable import Microprocessed

final class TRBTests: SystemTests {
    typealias DataSet = (input: UInt8, mask: UInt8, result: UInt8, zero: Bool)

    static let dataSet: [DataSet] = [
        (input: 0xFF, mask: 0x0F, result: 0xF0, zero: false),
        (input: 0x0F, mask: 0xFC, result: 0x03, zero: false),
        (input: 0xAA, mask: 0xAA, result: 0x00, zero: false)
    ]

    func testTRBZeroPage() throws {
        let opcode: UInt8 = 0x14

        for (input, mask, result, zero) in TRBTests.dataSet {
            try ram.write(to: 0x2D, data: input)
            mpu.registers.A = mask

            try mpu.execute(opcode, data: 0x2D)
            XCTAssert(try ram.read(from: 0x2D) == result)
            XCTAssert(mpu.registers.$SR.contains(.isZero) == zero, "\(input.hex), \(mask.hex), \(result), \(try! ram.read(from: 0x2D).hex)")
        }
    }

    func testTRBAbsolute() throws {
        let opcode: UInt8 = 0x1C

        for (input, mask, result, zero) in TRBTests.dataSet {
            try ram.write(to: 0xDDDD, data: input)
            mpu.registers.A = mask

            try mpu.execute(opcode, word: 0xDDDD)
            XCTAssert(try ram.read(from: 0xDDDD) == result)
            XCTAssert(mpu.registers.$SR.contains(.isZero) == zero, "\(input.hex), \(mask.hex), \(result), \(try! ram.read(from: 0x2D).hex)")
        }
    }
}
