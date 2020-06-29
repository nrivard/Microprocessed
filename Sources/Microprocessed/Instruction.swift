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
        case .immediate, .zeroPage, .relative, .zeroPageIndexed, .zeroPageIndirect, .zeroPageIndexedIndirect, .zeroPageIndirectIndexed:
            return 2
        case .absolute, .absoluteIndexed, .absoluteIndirect, .absoluteIndexedIndirect:
            return 3
        }
    }

    /// the number of rising edge clock ticks this instruction would have taken on a real MPU
//    public var ticks: UInt8 {
//        return 2 // TODO: need to figure this out!
//    }

    /// creates an instruction from memory with given register state.
    init(memory: MemoryAddressable, registers: Registers) throws {
        self.opcode = try memory.read(from: registers.PC)
        self.addressingMode = try AddressingMode(opcode, memory: memory, registers: registers)
    }

//    /// create a hardcoded instruction. potentially useful for testing
//    init(opcode: UInt8, addressingMode: AddressingMode) {
//        self.opcode = opcode
//        self.addressingMode = addressingMode
//    }
}
