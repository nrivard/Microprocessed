import XCTest
@testable import Microprocessed

final class SimpleProgramTest: SystemTests {

    static let program: [UInt8] = [
        0xA9, 0xFD, // LDA #$FD
    // Loop:
        0x69, 0x01, // ADC #$01
        0xD0, 0xFC, // BNE Loop
        0x00        // BRK
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()

        // write the program
        for (index, byte) in SimpleProgramTest.program.enumerated() {
            try ram.write(to: mpu.registers.PC + UInt16(index), data: byte)
        }

        // and then write a zero to irqVector
        try ram.write(toAddressStartingAt: Microprocessor.irqVector, word: 0)
    }

    func testSimpleProgram() throws {
        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFD)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFE)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFE)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFF)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFF)
        XCTAssert(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0x00)
        XCTAssertFalse(mpu.registers.statusFlags.contains(.isNegative))
        XCTAssert(mpu.registers.statusFlags.contains(.isZero))
        XCTAssert(mpu.registers.statusFlags.contains(.didCarry))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8006)

        let statusFlags = mpu.registers.statusFlags
        let pc = mpu.registers.PC

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0)
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == statusFlags.rawValue)
        XCTAssert(try mpu.popWord() == pc + 1)
    }
}
