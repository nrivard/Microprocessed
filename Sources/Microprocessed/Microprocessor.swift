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
    }

    /// send a single clock rising edge pulse to the `Microprocessor`
    public func tick() throws {
        try execute(try fetch())
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
                registers.A += 1
                result = registers.A
            } else if case .inx = instruction.mnemonic {
                registers.X += 1
                result = registers.X
            } else if case .iny = instruction.mnemonic {
                registers.Y += 1
                result = registers.Y
            } else if case .inc = instruction.mnemonic {
                let addr = try instruction.addressingMode.address(from: memory, registers: registers)
                result = try instruction.addressingMode.value(from: memory, registers: registers) + 1
                try memory.write(to: addr, data: result)
            } else {
                throw Error.undefinedInstruction
            }

            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))

        case .dea, .dex, .dey, .dec:
            let result: UInt8

            if case .dea = instruction.mnemonic {
                registers.A -= 1
                result = registers.A
            } else if case .dex = instruction.mnemonic {
                registers.X -= 1
                result = registers.X
            } else if case .dey = instruction.mnemonic {
                registers.Y -= 1
                result = registers.Y
            } else if case .dec = instruction.mnemonic {
                let addr = try instruction.addressingMode.address(from: memory, registers: registers)
                result = try instruction.addressingMode.value(from: memory, registers: registers) - 1
                try memory.write(to: addr, data: result)
            } else {
                throw Error.undefinedInstruction
            }

            registers.updateZero(for: UInt16(result))
            registers.updateSign(for: UInt16(result))
            
        case .nop:
            // already updated PC, so nothing to do
            break

        case .undefined:
            throw Error.undefinedInstruction
        }
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
