//
//  File.swift
//  
//
//  Created by Nate Rivard on 18/06/2020.
//

import Combine
import Foundation

/// microprocessor unit
///
/// Queries supplied `MemoryAddressable` object for instructions and data.
public class Microprocessor {

    public enum Error: Swift.Error {
        case undefinedInstruction
    }

    /// Memory layout that the MPU uses to fetch opcodes and data alike
    public unowned let memory: MemoryAddressable

    /// raw register state
    public internal(set) var registers: Registers = .init()

    /// create a `Microprocessor` with a given memory layout and configuration.
    ///
    /// NOTE: `memoryLayout` is `unowned`, so it is the creator's responsibility to keep
    /// both the created `Microprocessor` and `memoryLayout` strongly referenced
    public required init(memoryLayout memory: MemoryAddressable) {
        self.memory = memory
    }

    /// reset the `Microprocessor` register state and load `PC` at the `resetVector` address
    public func reset() throws {
        registers.PC = try memory.readWord(fromAddressStartingAt: Microprocessor.resetVector)
        registers.A = 0
        registers.X = 0
        registers.Y = 0
        registers.SP = 0xFF
        registers.SR = StatusFlags.alwaysSet.rawValue
    }

    /// send a single clock rising edge pulse to the `Microprocessor`
    public func tick() throws {
        try execute(try fetch())
    }
}

extension Microprocessor {

    /// send an interrupt signal. This may be ignored if `interruptsDisabled` is enabled
    /// TODO: create a software originated variant of this for BRK
    public func interrupt() throws {
        guard !registers.$SR.contains(.interruptsDisabled) else {
            return
        }

        try interrupt(toVector: Microprocessor.irqVector, isHardware: true)
    }

    /// send a non-maskable interrupt signal. This will always execute, even when `interruptsDisabled` is enabled
    public func nonMaskableInterrupt() throws {
        try interrupt(toVector: Microprocessor.nmiVector, isHardware: true)
    }

    private func interrupt(toVector vector: UInt16, isHardware: Bool) throws {
        // BRK instruction is actually supposed to push PC + 2, but it's addressing mode is `stack` which is size `1`. So if this is a software IRQ,
        // we need to compensate by adding 1 to PC
        let softwareOffset: UInt16 = isHardware ? 0 : 1
        try pushWord(registers.PC + softwareOffset)

        let mask: UInt8 = isHardware ? ~StatusFlags.isSoftwareInterrupt.rawValue : 0xFF
        try push(registers.SR & mask)

        // while in an interrupt routine, interrupts are disabled. this will get cleared (if it was previously cleared) when SR is restored
        registers.setInterruptsDisabled()

        registers.PC = try memory.readWord(fromAddressStartingAt: vector)
    }
}

extension Microprocessor {

    /// writes an opcode and 1-byte of data at the address pointed to by PC
    public func writeOpcode(_ opcode: UInt8, data: UInt8) throws {
        try memory.write(to: registers.PC, data: opcode)
        try memory.write(to: registers.PC + 1, data: data)
    }

    /// writes an opcode and 2-bytes of data at the address pointed to by PC
    public func writeOpcode(_ opcode: UInt8, word: UInt16) throws {
        try memory.write(to: registers.PC, data: opcode)
        try memory.write(toAddressStartingAt: registers.PC + 1, word: word)
    }
}

extension Microprocessor {

    /// fetch an instruction and increment the PC
    func fetch() throws -> Instruction {
        let instruction = try Instruction(memory: memory, registers: registers)
        registers.PC += instruction.size

        return instruction
    }

    /// execute the instruction and update status register
    func execute(_ instruction: Instruction) throws {
        switch instruction.mnemonic {

        case .lda, .ldx, .ldy:
            let result = try instruction.addressingMode.value(from: memory, registers: registers)
            updateSignZero(for: result)

            if case .lda = instruction.mnemonic {
                registers.A = result
            } else if case .ldx = instruction.mnemonic {
                registers.X = result
            } else if case .ldy = instruction.mnemonic {
                registers.Y = result
            }

        case .sta, .stx, .sty, .stz:
            let addr = try instruction.addressingMode.address(from: memory, registers: registers)

            let registerValue: UInt8
            if case .sta = instruction.mnemonic {
                registerValue = registers.A
            } else if case .stx = instruction.mnemonic {
                registerValue = registers.X
            } else if case .sty = instruction.mnemonic {
                registerValue = registers.Y
            } else if case .stz = instruction.mnemonic {
                registerValue = 0x00
            } else {
                // should never get here
                throw Error.undefinedInstruction
            }

            try memory.write(to: addr, data: registerValue)

        case .pha:
            try push(registers.A)
        case .phx:
            try push(registers.X)
        case .phy:
            try push(registers.Y)
        case .php:
            try push(registers.SR)

        case .pla, .plx, .ply, .plp:
            let result = try pop()
            updateSignZero(for: result)

            if case .pla = instruction.mnemonic {
                registers.A = result
            } else if case .plx = instruction.mnemonic {
                registers.X = result
            } else if case .ply = instruction.mnemonic {
                registers.Y = result
            } else if case .plp = instruction.mnemonic {
                // this should actually overwrite the status flag updates we just did which is good
                registers.SR = result
            } else {
                throw Error.undefinedInstruction
            }

        case .txs:
            registers.SP = registers.X

        case .tsx:
            registers.X = registers.SP
            updateSignZero(for: registers.X)

        case .ina, .inx, .iny, .inc:
            let result: UInt16

            if case .ina = instruction.mnemonic {
                result = UInt16(registers.A) + 1
                registers.A = result.truncated
            } else if case .inx = instruction.mnemonic {
                result = UInt16(registers.X) + 1
                registers.X = result.truncated
            } else if case .iny = instruction.mnemonic {
                result = UInt16(registers.Y) + 1
                registers.Y = result.truncated
            } else if case .inc = instruction.mnemonic {
                let addr = try instruction.addressingMode.address(from: memory, registers: registers)
                result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers)) + 1
                try memory.write(to: addr, data: result.truncated)
            } else {
                throw Error.undefinedInstruction
            }

            updateSignZero(for: result)

        case .dea, .dex, .dey, .dec:
            let result: UInt8

            if case .dea = instruction.mnemonic {
                result = registers.A &- 1
                registers.A = result
            } else if case .dex = instruction.mnemonic {
                result = registers.X &- 1
                registers.X = result
            } else if case .dey = instruction.mnemonic {
                result = registers.Y &- 1
                registers.Y = result
            } else if case .dec = instruction.mnemonic {
                let addr = try instruction.addressingMode.address(from: memory, registers: registers)
                result = try instruction.addressingMode.value(from: memory, registers: registers) &- 1
                try memory.write(to: addr, data: result)
            } else {
                throw Error.undefinedInstruction
            }

            updateSignZero(for: result)

        case .asl:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers)) << 1

            updateSignZero(for: result)
            registers.updateCarry(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .lsr:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = value >> 1

            updateSignZero(for: result)

            if value & 0x1 > 0 {
                registers.setCarry()
            } else {
                registers.clearCarry()
            }

            try save(result, addressingMode: instruction.addressingMode)

        case .rol:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = (value << 1) | (registers.$SR.contains(.didCarry) ? 1 : 0)

            updateSignZero(for: result)
            registers.updateCarry(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .ror:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = (value >> 1) | UInt16(registers.$SR.contains(.didCarry) ? (1 << 7) : 0)

            updateSignZero(for: result)

            if value & 0x1 > 0 {
                registers.setCarry()
            } else {
                registers.clearCarry()
            }

            try save(result, addressingMode: instruction.addressingMode)

        case .and:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) & registers.A)
            updateSignZero(for: result)

            registers.A = result.truncated

        case .ora:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) | registers.A)
            updateSignZero(for: result)

            registers.A = result.truncated

        case .eor:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) ^ registers.A)
            updateSignZero(for: result)

            registers.A = result.truncated

        case .bit:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = UInt16(registers.A) & value
            registers.updateZero(for: result)

            // weird trivia: BIT is the only 65C02 instruction where status flags are affected differently depending on
            // addressing mode. In this case, N and V are not affected in the newer immediate addressing mode, so just `break`
            if case .immediate = instruction.addressingMode {
                break
            }

            // mask for bits 6 and 7
            let mask: StatusFlags = [.isNegative, .didOverflow]

            // clear bits
            registers.SR &= ~mask.rawValue

            // then copy bits from memory location to SR
            registers.SR |= UInt8(value) & mask.rawValue

        case .cmp:
            try compare(registers.A, addressingMode: instruction.addressingMode)
        case .cpx:
            try compare(registers.X, addressingMode: instruction.addressingMode)
        case .cpy:
            try compare(registers.Y, addressingMode: instruction.addressingMode)

        case .trb:
            let result = UInt16(~registers.A & (try instruction.addressingMode.value(from: memory, registers: registers)))
            registers.updateZero(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .tsb:
            let result = UInt16(registers.A | (try instruction.addressingMode.value(from: memory, registers: registers)))
            registers.updateZero(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .rmb:
            let mask = instruction.resetOpcodeBitMask
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) & mask)

            try save(result, addressingMode: instruction.addressingMode)
            
        case .smb:
            let mask = instruction.setOpcodeBitMask
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) | mask)

            try save(result, addressingMode: instruction.addressingMode)

        case .adc:
            let value = try instruction.addressingMode.value(from: memory, registers: registers)
            arithmeticAdd(value)

        case .sbc:
            let value: UInt8
            let byte = try instruction.addressingMode.value(from: memory, registers: registers)
            if registers.$SR.contains(.decimalMode) {
                // a 10's complement operand
                value = 0x99 &- byte
            } else {
                // a 1's complement operand. with carry this will become 2's complement
                value = ~byte
            }
            arithmeticAdd(value)

        case .jmp:
            registers.PC = try instruction.addressingMode.address(from: memory, registers: registers)

        case .jsr:
            // writes the *address* of the last byte of the instruction to the stack
            // this is effectively the current PC (which has already been incremented to the _next_ instruction) - 1
            try pushWord(registers.PC - 1)
            registers.PC = try instruction.addressingMode.address(from: memory, registers: registers)

        case .rts:
            // return address was stored as last byte of prev instruction, so add 1 to get to the actual return instruction address
            registers.PC = try popWord() + 1

        case .rti:
            // restore status register first. make sure to set `isSoftwareInterrupt` as this is always a `1` in the actual register
            registers.SR = try pop()
            registers.PC = try popWord()

        case .bra:
            try branch(on: true, addressingMode: instruction.addressingMode)
        case .beq:
            try branch(on: registers.$SR.contains(.isZero), addressingMode: instruction.addressingMode)
        case .bne:
            try branch(on: !registers.$SR.contains(.isZero), addressingMode: instruction.addressingMode)
        case .bcc:
            try branch(on: !registers.$SR.contains(.didCarry), addressingMode: instruction.addressingMode)
        case .bcs:
            try branch(on: registers.$SR.contains(.didCarry), addressingMode: instruction.addressingMode)
        case .bvs:
            try branch(on: registers.$SR.contains(.didOverflow), addressingMode: instruction.addressingMode)
        case .bvc:
            try branch(on: !registers.$SR.contains(.didOverflow), addressingMode: instruction.addressingMode)
        case .bmi:
            try branch(on: registers.$SR.contains(.isNegative), addressingMode: instruction.addressingMode)
        case .bpl:
            try branch(on: !registers.$SR.contains(.isNegative), addressingMode: instruction.addressingMode)
        case .bbr:
            let mask = instruction.resetOpcodeBitMask
            let zeroPageAddr = try instruction.addressingMode.value(from: memory, registers: registers)
            let value = try memory.read(from: UInt16(zeroPageAddr))

            try branch(on: value & mask == 0, addressingMode: instruction.addressingMode)
        case .bbs:
            let mask = instruction.setOpcodeBitMask
            let value = try instruction.addressingMode.value(from: memory, registers: registers)

            try branch(on: value & mask > 0, addressingMode: instruction.addressingMode)

        case .clc:
            registers.clearCarry()
        case .cld:
            registers.clearDecimal()
        case .cli:
            registers.clearInterruptsDisabled()
        case .clv:
            registers.clearOverflow()
        case .sec:
            registers.setCarry()
        case .sed:
            registers.setDecimal()
        case .sei:
            registers.setInterruptsDisabled()

        case .tax:
            registers.X = registers.A
            updateSignZero(for: registers.X)
        case .tay:
            registers.Y = registers.A
            updateSignZero(for: registers.Y)
        case .txa:
            registers.A = registers.X
            updateSignZero(for: registers.A)
        case .tya:
            registers.A = registers.Y
            updateSignZero(for: registers.A)
            
        case .nop:
            // already updated PC, so nothing to do
            break

        case .brk:
            try interrupt(toVector: Microprocessor.irqVector, isHardware: false)

        case .undefined:
            throw Error.undefinedInstruction
        }
    }
}

extension Microprocessor {

    /// saves values either to the accumulator or referenced memory location
    ///
    /// NOTE: this is useful for arithmetic instructions
    private func save(_ value: UInt16, addressingMode: Instruction.AddressingMode) throws {
        let truncatedValue = UInt8(value & 0x00FF)

        guard addressingMode != .accumulator else {
            registers.A = truncatedValue
            return
        }

        let addr = try addressingMode.address(from: memory, registers: registers)
        try memory.write(to: addr, data: truncatedValue)
    }
}

extension Microprocessor {

    private func compare(_ register: UInt8, addressingMode: Instruction.AddressingMode) throws {
        let value = UInt16(try addressingMode.value(from: memory, registers: registers))

        let result = UInt16(register) &- value
        registers.updateSign(for: result)
        registers.updateZero(for: result)

        if register >= value {
            registers.setCarry()
        } else {
            registers.clearCarry()
        }

//        print("Comparing \(register.hex) - \(value.hex) = \(result.hex)")
    }

    private func arithmeticAdd(_ value: UInt8) {
        let result: UInt16
        
        if !registers.$SR.contains(.decimalMode) {
            result = [registers.A, value, registers.arithmeticCarry].map(UInt16.init).reduce(0, +)
            registers.updateCarry(for: result)
        } else {
            var lowByte = (registers.A & 0x0F) + (value & 0x0F) + registers.arithmeticCarry
            var highByte = (registers.A & 0xF0) + (value & 0x0F)
            var shouldCarry = false

            if lowByte >= 0x0A {
                lowByte -= 0x0A
                highByte += 0x10
            }

            if highByte >= 0xA0 {
                highByte -= 0xA0
                shouldCarry = true
            }

            if shouldCarry {
                registers.setCarry()
            } else {
                registers.clearCarry()
            }

            result = UInt16(highByte << 4) | UInt16(lowByte)
        }

        registers.updateSign(for: result)
        registers.updateZero(for: result)
        registers.updateOverflow(for: result, leftOperand: value, rightOperand: registers.A)

        registers.A = result.truncated

//        print("Adding \(registers.A.hex) + \(value.hex) = \(registers.A.hex), SR: \(registers.SR.bin)")
    }

    private func branch(on condition: @autoclosure () throws -> Bool, addressingMode: Instruction.AddressingMode) throws {
        guard try condition() else {
            return
        }

        registers.PC = try addressingMode.address(from: memory, registers: registers)
    }

    private func updateSignZero(for result: UInt8) {
        updateSignZero(for: UInt16(result))
    }

    private func updateSignZero(for result: UInt16) {
        registers.updateSign(for: result)
        registers.updateZero(for: result)
    }
}

extension Microprocessor {

    /// non-maskable interrupt vector. when NMI is encountered, the MPU will request the address of the ISR at this address
    public static let nmiVector: UInt16 = 0xFFFA
    public static let nmiVectorHigh: UInt16 = nmiVector + 1

    /// reset interrupt vector. when a reset occurs, the MPU will request the address for code start at this address
    public static let resetVector: UInt16 = 0xFFFC
    public static let resetVectorHigh: UInt16 = resetVector + 1

    /// interrupt vector. when an interrupt occurs, the MPU will request the address of the ISR at this address
    public static let irqVector: UInt16 = 0xFFFE
    public static let irqVectorHight: UInt16 = irqVector + 1
}
