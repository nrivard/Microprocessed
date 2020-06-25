//
//  File.swift
//  
//
//  Created by Nate Rivard on 23/06/2020.
//

import Foundation

/// A `Microprocessor` instruction
public struct Instruction {

    public let opcode: UInt8
    public let addressingMode: AddressingMode

    /// the human readable mnemonic of the instruction
    public var mnemonic: Mnemonic {
        return Mnemonic(opcode)
    }

    /// the memory span of the instruction
    public var size: UInt16 {
        switch addressingMode {
        case .implied, .stack, .accumulator:
            return 1
        case .immediate, .zeroPage:
            return 2
        }
    }

    /// the number of rising edge clock ticks this instruction would have taken on a real MPU
    public var ticks: UInt8 {
        return 2 // TODO: need to figure this out!
    }

    /// creates an instruction from memory with given register state.
    init(memory: MemoryAddressable, registers: Microprocessor.Registers) throws {
        self.opcode = try memory.read(from: registers.PC)
        self.addressingMode = try AddressingMode(opcode, memory: memory, registers: registers)
    }
}

