import XCTest
@testable import Microprocessed

final class BITTests: SystemTests {

    /// results. `interrupts_disabled` is set in setup and should remain unchanged in _all_ tests
    static let results: [(memory: UInt8, result: UInt8)] = [
        (0b1000_0000, 0b1011_0100),
        (0b0100_0000, 0b0111_0100),
        (0b0011_1111, 0b0011_0100),
        (0b0000_0000, 0b0011_0110),
        (0b1100_1111, 0b1111_0100)
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()

        mpu.registers.A = 0xFF
        mpu.registers.SR |= StatusFlags.interruptsDisabled.rawValue
    }

    func testBITImmediate() throws {
        let opcode: UInt8 = 0x89

        for (memory, result) in BITTests.results {
            try mpu.execute(opcode, data: memory)
            
            // immediate mode does NOT affect NV. so mask those bits out
            XCTAssert(mpu.registers.SR == result & 0x3F, "Expected \(result), got \(mpu.registers.SR)")
            XCTAssert(mpu.registers.A == 0xFF) // A is unchanged
        }
    }

    func testBITZeroPage() throws {
        let opcode: UInt8 = 0x24

        for (memory, result) in BITTests.results {
            try ram.write(to: 0x80, data: memory)

            try mpu.execute(opcode, data: 0x80)
            XCTAssert(mpu.registers.SR == result)
            XCTAssert(mpu.registers.A == 0xFF) // A is unchanged
            XCTAssert(try ram.read(from: 0x0080) == memory) // original memory value unchanged
        }
    }

    func testBITZeroPageIndexed() throws {
        let opcode: UInt8 = 0x34

        for (memory, result) in BITTests.results {
            try ram.write(to: 0x84, data: memory)
            mpu.registers.X = 0x04

            try mpu.execute(opcode, data: 0x80)
            XCTAssert(mpu.registers.SR == result)
            XCTAssert(mpu.registers.A == 0xFF) // A is unchanged
            XCTAssert(try ram.read(from: 0x0084) == memory) // original memory value unchanged
        }
    }

    func testBITAbsolute() throws {
        let opcode: UInt8 = 0x2C
        let address: UInt16 = 0xA5DF

        for (memory, result) in BITTests.results {
            try ram.write(to: address, data: memory)

            try mpu.execute(opcode, word: address)
            XCTAssert(mpu.registers.SR == result)
            XCTAssert(mpu.registers.A == 0xFF) // A is unchanged
            XCTAssert(try ram.read(from: address) == memory) // original memory value unchanged
        }
    }

    func testBITAbsoluteIndexed() throws {
        let opcode: UInt8 = 0x3C
        let address: UInt16 = 0xA5D0
        let finalAddress: UInt16 = 0xA5DF

        for (memory, result) in BITTests.results {
            try ram.write(to: finalAddress, data: memory)
            mpu.registers.X = 0x0F

            try mpu.execute(opcode, word: address)
            XCTAssert(mpu.registers.SR == result)
            XCTAssert(mpu.registers.A == 0xFF) // A is unchanged
            XCTAssert(try ram.read(from: finalAddress) == memory) // original memory value unchanged
        }
    }
}
