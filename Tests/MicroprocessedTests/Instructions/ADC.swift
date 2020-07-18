import XCTest
@testable import Microprocessed

final class ADCTests: SystemTests {
    typealias DataSet = (input: UInt8, accum: UInt8, inputFlags: StatusFlags, result: UInt8, outputFlags: StatusFlags)

    static let dataSet: [DataSet] = [
        (input: 0x10, accum: 0x05, inputFlags: [], result: 0x15, outputFlags: []), // normal addition, no input carry
        (input: 0x01, accum: 0xFF, inputFlags: [], result: 0x00, outputFlags: [.didCarry, .isZero]), // carry, isZero
        (input: 0x05, accum: 0x05, inputFlags: [.didCarry], result: 0x0B, outputFlags: []), // input carry
        (input: 0x80, accum: 0x01, inputFlags: [], result: 0x81, outputFlags: [.isNegative]),
        (input: 0x50, accum: 0x50, inputFlags: [], result: 0xA0, outputFlags: [.isNegative, .didOverflow]) // negative, overflow
    ]

    func testADCImmediate() throws {
        let opcode: UInt8 = 0x69

        try runDataSet {
            try mpu.execute(opcode, data: $0)
        }
    }

    func testADCZeroPage() throws {
        let opcode: UInt8 = 0x65

        try runDataSet {
            try ram.write(to: 0x50, data: $0)
            try mpu.execute(opcode, data: 0x50)
        }
    }

    func testADCZeroPageIndexed() throws {
        let opcode: UInt8 = 0x75

        try runDataSet {
            try ram.write(to: 0x15, data: $0)
            mpu.registers.X = 0x05

            try mpu.execute(opcode, data: 0x10)
        }
    }

    func testADCAbsolute() throws {
        let opcode: UInt8 = 0x6D
        let address: UInt16 = 0xA5DF

        try runDataSet {
            try ram.write(to: address, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testADCAbsoluteIndexedX() throws {
        let opcode: UInt8 = 0x7D
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.X = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testADCAbsoluteIndexedY() throws {
        let opcode: UInt8 = 0x79
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF
        mpu.registers.Y = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try mpu.execute(opcode, word: address)
        }
    }

    func testADCZeroPageIndexedIndirect() throws {
        let opcode: UInt8 = 0x61
        let address: UInt16 = 0xA5DF
        mpu.registers.X = 0x05

        try runDataSet {
            try ram.write(to: address, data: $0)
            try ram.write(toAddressStartingAt: 0x0A, word: address)
            try mpu.execute(opcode, data: 0x05)
        }
    }

    func testADCZeroPageIndirectIndexed() throws {
        let opcode: UInt8 = 0x71
        let finalAddress: UInt16 = 0xA5DF
        let address: UInt16 = 0xA5D0
        mpu.registers.Y = 0x0F

        try runDataSet {
            try ram.write(to: finalAddress, data: $0)
            try ram.write(toAddressStartingAt: 0x010, word: address)
            try mpu.execute(opcode, data: 0x10)
        }
    }

    func testADCZeroPageIndirect() throws {
        let opcode: UInt8 = 0x72
        let address: UInt16 = 0xA5DF

        try runDataSet {
            try ram.write(to: address, data: $0)
            try ram.write(toAddressStartingAt: 0x0A, word: address)
            try mpu.execute(opcode, data: 0x0A)
        }
    }

    func testADCDecimal() throws {
        let opcode: UInt8 = 0x69
        mpu.registers.setDecimal()

        mpu.registers.A = 0x0
        try mpu.execute(opcode, data: 0x0)

        XCTAssert(mpu.registers.A == 0)

        mpu.registers.setCarry()
        try mpu.execute(opcode, data: 0x0)

        XCTAssert(mpu.registers.A == 1)

        mpu.registers.clearCarry()
        mpu.registers.A = 0x01
        try mpu.execute(opcode, data: 0x01)

        XCTAssert(mpu.registers.A == 2)

        mpu.registers.A = 0x05
        try mpu.execute(opcode, data: 0x05)

        XCTAssert(mpu.registers.A == 0x10)

        mpu.registers.A = 0x58
        try mpu.execute(opcode, data: 0x46)

        XCTAssert(mpu.registers.A == 0x04)
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
    }
}

extension ADCTests {

    private func runDataSet(executing execution: (_ input: UInt8) throws -> Void) rethrows {
        for (input, accum, inputFlags, result, outputFlags) in ADCTests.dataSet {
            mpu.registers.A = accum
            mpu.registers.SR = inputFlags.rawValue

            try execution(input)

            let realWorld = outputFlags.union([.alwaysSet, .isSoftwareInterrupt])
            XCTAssert(mpu.registers.A == result, String(format: "Expected %X, got %X", result, mpu.registers.A))
            XCTAssert(mpu.registers.$SR == realWorld, String(format: "Expected %X, got %X", outputFlags.rawValue, mpu.registers.$SR.rawValue))
        }
    }
}
