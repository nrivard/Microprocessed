import XCTest
@testable import Microprocessed

final class MicroprocessorTests: SystemTests {

    func testFetch() throws {
        XCTAssert(mpu.registers.PC == 0x8000)

        let instruction = try mpu.fetch()
        XCTAssert(mpu.registers.PC == 0x8001)
        XCTAssert(instruction.mnemonic ~= .nop)
        XCTAssert(instruction.size == 1)
    }

    func testUndefinedInstruction() throws {
        for opcode in Instruction.AddressingMode.Opcodes.unused {
            XCTAssertThrowsError(try mpu.execute(opcode, data: 0x00))
        }
    }

    func testLoadStatusFlags() throws {
        // uses all immediate address modes
        try mpu.testLoadImmediateStatusFlags(for: 0xA9)
        try mpu.testLoadImmediateStatusFlags(for: 0xA2)
        try mpu.testLoadImmediateStatusFlags(for: 0xA0)
    }

    func testInterrupt() throws {
        let returnAddress = mpu.registers.PC
        let irqAddress: UInt16 = 0xA5DF
        let status: StatusFlags = [.isNegative, .didCarry, .didOverflow, .alwaysSet, .isSoftwareInterrupt]
        try ram.write(toAddressStartingAt: Microprocessor.irqVector, word: irqAddress)
        mpu.registers.SR = status.rawValue

        try mpu.interrupt()
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == status.subtracting(.isSoftwareInterrupt).rawValue)
        XCTAssert(try mpu.popWord() == returnAddress)

        // we artifically popped the stack but interrupts should still be disabled
        try mpu.interrupt()
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))
    }

    func testNonmaskableInterrupt() throws {
        let returnAddress = mpu.registers.PC
        let irqAddress: UInt16 = 0xA5DF
        let status: StatusFlags = [.isNegative, .didCarry, .didOverflow, .alwaysSet, .isSoftwareInterrupt]
        try ram.write(toAddressStartingAt: Microprocessor.nmiVector, word: irqAddress)
        mpu.registers.SR = status.rawValue

        try mpu.nonMaskableInterrupt()
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == status.subtracting(.isSoftwareInterrupt).rawValue)
        XCTAssert(try mpu.popWord() == returnAddress)

        // lets test nested NMI interrupts :)
        // this shouldn't really happen in practice, since my ROM isn't writeable but hey, it's supported in theory
        let anotherIRQAddress: UInt16 = 0x5005
        try ram.write(toAddressStartingAt: Microprocessor.nmiVector, word: anotherIRQAddress)

        try mpu.nonMaskableInterrupt()
        XCTAssert(mpu.registers.PC == anotherIRQAddress)
        XCTAssert(mpu.registers.statusFlags.contains(.interruptsDisabled))
    }
}

extension Microprocessor {

    /// convenience for executing an operandless opcode
    func execute(_ opcode: UInt8) throws {
        try memory.write(to: registers.PC, data: opcode)
        try tick()
    }

    /// convenience that writes an opcode and data, then executes it
    func execute(_ opcode: UInt8, data: UInt8) throws {
        try writeOpcode(opcode, data: data)
        try tick()
    }

    /// convenience that writes an opcode and word, then executes it
    func execute(_ opcode: UInt8, word: UInt16) throws {
        try writeOpcode(opcode, word: word)
        try tick()
    }

    func testLoadImmediateStatusFlags(for opcode: UInt8) throws {
        try execute(opcode, data: 0x00)
        XCTAssert(registers.statusFlags.contains(.isZero))
        XCTAssertFalse(registers.statusFlags.contains(.isNegative))

        try execute(opcode, data: 0x80)
        XCTAssertFalse(registers.statusFlags.contains(.isZero))
        XCTAssert(registers.statusFlags.contains(.isNegative))

        try execute(opcode, data: 0x70)
        XCTAssertFalse(registers.statusFlags.contains(.isZero))
        XCTAssertFalse(registers.statusFlags.contains(.isNegative))
    }
}
