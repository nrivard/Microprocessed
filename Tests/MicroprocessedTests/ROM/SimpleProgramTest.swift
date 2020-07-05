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
        try ram.writeProgram(SimpleProgramTest.program, startingAtAddress: mpu.registers.PC)

        // and then write a zero to irqVector
        try ram.write(toAddressStartingAt: Microprocessor.irqVector, word: 0)
    }

    func testSimpleProgram() throws {
        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFD)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFE)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFE)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFF)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0xFF)
        XCTAssert(mpu.registers.$SR.contains(.isNegative))
        XCTAssertFalse(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.PC == 0x8002)

        try mpu.tick()
        XCTAssert(mpu.registers.A == 0x00)
        XCTAssertFalse(mpu.registers.$SR.contains(.isNegative))
        XCTAssert(mpu.registers.$SR.contains(.isZero))
        XCTAssert(mpu.registers.$SR.contains(.didCarry))
        XCTAssert(mpu.registers.PC == 0x8004)

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8006)

        let statusFlags = mpu.registers.$SR
        let pc = mpu.registers.PC

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == statusFlags.rawValue)
        XCTAssert(try mpu.popWord() == pc + 1)
    }
}
