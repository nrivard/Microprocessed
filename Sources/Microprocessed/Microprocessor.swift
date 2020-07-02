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
        guard !registers.statusFlags.contains(.interruptsDisabled) else {
            return
        }

        try interrupt(toVector: Microprocessor.irqVector)
    }

    /// send a non-maskable interrupt signal. This will always execute, even when `interruptsDisabled` is enabled
    public func nonMaskableInterrupt() throws {
        try interrupt(toVector: Microprocessor.nmiVector)
    }

    private func interrupt(toVector vector: UInt16) throws {
        try pushWord(registers.PC)
        try push(registers.SR)

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
            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))

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

        case .pha, .phx, .phy, .php:
            let registerValue: UInt8

            if case .pha = instruction.mnemonic {
                registerValue = registers.A
            } else if case .phx = instruction.mnemonic {
                registerValue = registers.X
            } else if case .phy = instruction.mnemonic {
                registerValue = registers.Y
            } else if case .php = instruction.mnemonic {
                registerValue = registers.SR
            } else {
                throw Error.undefinedInstruction
            }

            try push(registerValue)

        case .pla, .plx, .ply, .plp:
            let result = try pop()
            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))

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
            registers.updateZero(for: UInt16(registers.X))
            registers.updateSign(for: UInt16(registers.X))

        case .ina, .inx, .iny, .inc:
            let result: UInt8

            if case .ina = instruction.mnemonic {
                result = registers.A &+ 1
                registers.A = result
            } else if case .inx = instruction.mnemonic {
                result = registers.X &+ 1
                registers.X = result
            } else if case .iny = instruction.mnemonic {
                result = registers.Y &+ 1
                registers.Y = result
            } else if case .inc = instruction.mnemonic {
                let addr = try instruction.addressingMode.address(from: memory, registers: registers)
                result = try instruction.addressingMode.value(from: memory, registers: registers) &+ 1
                try memory.write(to: addr, data: result)
            } else {
                throw Error.undefinedInstruction
            }

            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))

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

            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))

        case .asl:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers)) << 1

            registers.updateZero(for: result)
            registers.updateSign(for: result)
            registers.updateCarry(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .lsr:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = value >> 1

            registers.updateZero(for: result)
            registers.updateSign(for: result)

            if value & 0x1 > 0 {
                registers.setCarry()
            } else {
                registers.clearCarry()
            }

            try save(result, addressingMode: instruction.addressingMode)

        case .rol:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = (value << 1) | (registers.statusFlags.contains(.didCarry) ? 1 : 0)

            registers.updateZero(for: result)
            registers.updateSign(for: result)
            registers.updateCarry(for: result)

            try save(result, addressingMode: instruction.addressingMode)

        case .ror:
            let value = UInt16(try instruction.addressingMode.value(from: memory, registers: registers))
            let result = (value >> 1) | UInt16(registers.statusFlags.contains(.didCarry) ? (1 << 7) : 0)

            registers.updateZero(for: result)
            registers.updateSign(for: result)

            if value & 0x1 > 0 {
                registers.setCarry()
            } else {
                registers.clearCarry()
            }

            try save(result, addressingMode: instruction.addressingMode)

        case .and:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) & registers.A)
            registers.updateZero(for: result)
            registers.updateSign(for: result)

            registers.A = result.truncated

        case .ora:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) | registers.A)
            registers.updateZero(for: result)
            registers.updateSign(for: result)

            registers.A = result.truncated

        case .eor:
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) ^ registers.A)
            registers.updateZero(for: result)
            registers.updateSign(for: result)

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
            // opcodes are 0xN7 where N is the bit index that is being reset. so take that half the byte to form the mask
            //
            // ex: 0x47 resets bit 4
            let mask: UInt8 = ~(1 << (instruction.opcode >> 4))
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) & mask)

            try save(result, addressingMode: instruction.addressingMode)
            
        case .smb:
            // opcodes are 0x(N+8)7 where N is the bit index that is being set (which is why 8 is subtracted.) so take that half of the byte
            // to form the mask
            //
            // ex: 0xA7 resets bit 2
            let mask: UInt8 = 1 << ((instruction.opcode >> 4) - 0x08)
            let result = UInt16(try instruction.addressingMode.value(from: memory, registers: registers) | mask)

            try save(result, addressingMode: instruction.addressingMode)

        case .adc:
            let value = try instruction.addressingMode.value(from: memory, registers: registers)
            arithmeticAdd(value)

        case .sbc:
            // this performs a 2s complement addition (if `carry` is set) since we can handle overflow but not underflow.
            // also just how this damn proc works
            let value = ~(try instruction.addressingMode.value(from: memory, registers: registers))
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
            // restore status register first
            registers.SR = try pop()
            registers.PC = try popWord()

        case .bra:
            registers.PC = try instruction.addressingMode.address(from: memory, registers: registers)

        case .beq:
            guard registers.statusFlags.contains(.isZero) else {
                break
            }

            registers.PC = try instruction.addressingMode.address(from: memory, registers: registers)
            
        case .nop:
            // already updated PC, so nothing to do
            break

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
    }

    private func arithmeticAdd(_ value: UInt8) {
        let result = [registers.A, value, registers.arithmeticCarry].map(UInt16.init).reduce(0, +)

        registers.updateSign(for: result)
        registers.updateZero(for: result)
        registers.updateCarry(for: result)
        registers.updateOverflow(for: result, leftOperand: value, rightOperand: registers.A)

        registers.A = result.truncated
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
