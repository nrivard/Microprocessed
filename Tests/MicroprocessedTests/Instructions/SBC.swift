import XCTest
@testable import Microprocessed

final class SBCTests: SystemTests {
    typealias DataSet = (input: UInt8, accum: UInt8, inputFlags: StatusFlags, result: UInt8, outputFlags: StatusFlags)

    static let dataSet: [DataSet] = [
        (input: 0x10, accum: 0x25, inputFlags: [.didCarry], result: 0x15, outputFlags: [.didCarry]), // normal subtraction with input carry
        (input: 0x02, accum: 0x01, inputFlags: [.didCarry], result: 0xFF, outputFlags: [.isNegative]), // carry, isZero
        (input: 0x05, accum: 0x0A, inputFlags: [], result: 0x04, outputFlags: [.didCarry]), // without input carry
        (input: 0xB0, accum: 0x50, inputFlags: [.didCarry], result: 0xA0, outputFlags: [.isNegative, .didOverflow]), // negative, overflow
        (input: 0x70, accum: 0xD0, inputFlags: [.didCarry], result: 0x60, outputFlags: [.didCarry, .didOverflow])
    ]

    func testSBCImmediate() throws {
        let opcode: UInt8 = 0xE9

        try runDataSet {
            try mpu.execute(opcode, data: $0)
        }
    }

    func testSBCZeroPage() throws {
        let opcode: UInt8 = 0xE5

        try runDataSet {
            try ram.write(to: 0x50, data: $0)
            try mpu.execute(opcode, data: 0x50)
        }
    }

    func testSBCZeroPageIndexed() throws {
        let opcode: UInt8 = 0xF5

        try runDataSet {
            try ram.write(to: 0x15, data: $0)
            mpu.registers.X = 0x05

            try mpu.execute(opcode, data: 0x10)
        }
    }

    func testSBCAbsolute() throws {
        let opcode: UInt8 = 0xED
        let address: UInt16 = 0xA5DF

        try runDataSet {
            try ram.write(to: address, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testSBCAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0xFD
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.X = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testSBCAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0xF9
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.Y = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testSBCZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0xE1
        let address: UInt16 = 0xA5DF
        mpu.registers.X = 0x05

        try runDataSet {
            try ram.write(to: address, data: $0)
            try ram.write(toAddressStartingAt: 0x0A, word: address)
            try mpu.execute(opcode, data: 0x05)
        }
    }

    func testSBCZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0xF1
        let finalAddress: UInt16 = 0xA5DF
        let address: UInt16 = 0xA5D0
        mpu.registers.Y = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try ram.write(toAddressStartingAt: 0x010, word: address)
            try mpu.execute(opcode, data: 0x10)
        }
    }

    func testSBCZeroPageIndirect() throws {
        let opcode: UInt8 = 0xF2
        let address: UInt16 = 0xA5DF

        try runDataSet {
            try ram.write(to: address, data: $0)
            try ram.write(toAddressStartingAt: 0x0A, word: address)
            try mpu.execute(opcode, data: 0x0A)
        }
    }
}

extension SBCTests {

    private func runDataSet(executing execution: (_ input: UInt8) throws -> Void) rethrows {
        for (input, accum, inputFlags, result, outputFlags) in SBCTests.dataSet {
            mpu.registers.A = accum
            mpu.registers.SR = inputFlags.rawValue

            try execution(input)

            XCTAssert(mpu.registers.A == result, String(format: "Expected %X, got %X", result, mpu.registers.A))
            XCTAssert(mpu.registers.$SR == outputFlags, String(format: "Expected %X, got %X", outputFlags.rawValue, mpu.registers.$SR.rawValue))
        }
    }
}
