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
    public let mnemonic: Mnemonic
    public let addressingMode: AddressingMode

    /// the memory span of the instruction
    public var size: UInt16 {
        switch addressingMode {
        case .implied, .stack, .accumulator:
            return 1
        case .immediate, .zeroPage, .relative, .zeroPageIndexed, .zeroPageIndirect, .zeroPageIndexedIndirect, .zeroPageIndirectIndexed:
            return 2
        case .absolute, .absoluteIndexed, .absoluteIndirect, .absoluteIndexedIndirect, .zeroPageThenRelative:
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
        self.mnemonic = .init(opcode)
        self.addressingMode = try .init(opcode, memory: memory, registers: registers)
    }

//    /// create a hardcoded instruction. potentially useful for testing
//    init(opcode: UInt8, addressingMode: AddressingMode) {
//        self.opcode = opcode
//        self.addressingMode = addressingMode
//    }
}

extension Instruction {

    /// returns a mask with the bit index based on a `reset` (or clear) opcode. This is suitable for use with the RMB• and BBR• instructions
    /// where the bit index is encoded in the upper half of the opcode
    ///
    /// ex: RMB4 has an opcode of 0x47 which resets bit 4
    var resetOpcodeBitMask: UInt8 {
        return (1 << (opcode >> 4))
    }

    /// returns a mask with the bit index based on a `set` opcode. This is suitable for use with the SMB• and BBS• instructions
    /// where the bit index is encoded in the upper half of the opcode
    ///
    /// ex: BBS2 has an opcode of 0xAF which resets bit 2
    var setOpcodeBitMask: UInt8 {
        return 1 << ((opcode >> 4) - 0x08)
    }
}

extension Instruction: CustomStringConvertible {

    public var description: String {
        return String(format: "\(mnemonic) \(addressingMode)   ; \(opcode)")
    }
}
