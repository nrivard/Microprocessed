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
        // first test that we'll throw if config is default
        for opcode in Instruction.Mnemonic.Opcodes.unused {
            XCTAssertThrowsError(try mpu.execute(opcode, data: 0x00))
        }

        // now test that if we change the configuration, we should just get a NOP
        let unrestrainedMPU = Microprocessor(memoryLayout: ram, configuration: .init(warnOnUnusedOpcodes: false))
        let unused1 = Instruction.AddressingMode.Opcodes.unused1.first!
        let unused2 = Instruction.AddressingMode.Opcodes.unused2.first!
        let unused3 = Instruction.AddressingMode.Opcodes.unused3.first!

        var pc = unrestrainedMPU.registers.PC
        try unrestrainedMPU.execute(unused1)
        XCTAssert(unrestrainedMPU.registers.PC == pc + 1)

        pc = unrestrainedMPU.registers.PC
        try unrestrainedMPU.execute(unused2)
        XCTAssert(unrestrainedMPU.registers.PC == pc + 2)

        pc = unrestrainedMPU.registers.PC
        try unrestrainedMPU.execute(unused3)
        XCTAssert(unrestrainedMPU.registers.PC == pc + 3)
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
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == status.subtracting(.isSoftwareInterrupt).rawValue)
        XCTAssert(try mpu.popWord() == returnAddress)

        // we artifically popped the stack but interrupts should still be disabled
        try mpu.interrupt()
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
    }

    func testNonmaskableInterrupt() throws {
        let returnAddress = mpu.registers.PC
        let irqAddress: UInt16 = 0xA5DF
        let status: StatusFlags = [.isNegative, .didCarry, .didOverflow, .alwaysSet, .isSoftwareInterrupt]
        try ram.write(toAddressStartingAt: Microprocessor.nmiVector, word: irqAddress)
        mpu.registers.SR = status.rawValue

        try mpu.nonMaskableInterrupt()
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == status.subtracting(.isSoftwareInterrupt).rawValue)
        XCTAssert(try mpu.popWord() == returnAddress)

        // lets test nested NMI interrupts :)
        // this shouldn't really happen in practice, since my ROM isn't writeable but hey, it's supported in theory
        let anotherIRQAddress: UInt16 = 0x5005
        try ram.write(toAddressStartingAt: Microprocessor.nmiVector, word: anotherIRQAddress)

        try mpu.nonMaskableInterrupt()
        XCTAssert(mpu.registers.PC == anotherIRQAddress)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
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
        XCTAssert(registers.$SR.contains(.isZero))
        XCTAssertFalse(registers.$SR.contains(.isNegative))

        try execute(opcode, data: 0x80)
        XCTAssertFalse(registers.$SR.contains(.isZero))
        XCTAssert(registers.$SR.contains(.isNegative))

        try execute(opcode, data: 0x70)
        XCTAssertFalse(registers.$SR.contains(.isZero))
        XCTAssertFalse(registers.$SR.contains(.isNegative))
    }
}
