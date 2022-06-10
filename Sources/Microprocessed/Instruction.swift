//
//  Instruction.swift
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
        case .implied, .stack, .accumulator, .unused1:
            return 1
        case .immediate, .zeroPage, .relative, .zeroPageIndexed, .zeroPageIndirect, .zeroPageIndexedIndirect, .zeroPageIndirectIndexed, .unused2:
            return 2
        case .absolute, .absoluteIndexed, .absoluteIndirect, .absoluteIndexedIndirect, .zeroPageThenRelative, .unused3:
            return 3
        }
    }

    /// creates an instruction from memory with given register state.
    init(memory: MemoryAddressable, registers: Registers) throws {
        self.opcode = try memory.read(from: registers.PC)
        self.mnemonic = .init(opcode)
        self.addressingMode = try .init(opcode, memory: memory, registers: registers)
    }

    /// creates an instruction from passed in params. This is not used anywhere in Microprocessed itself and instead
    /// is provided to create an instruction externally. Given that, this initializer does _no verification_
    public init(opcode: UInt8, mnemonic: Mnemonic, addressingMode: AddressingMode) {
        self.opcode = opcode
        self.mnemonic = mnemonic
        self.addressingMode = addressingMode
    }
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
        return disassembled + "    ; opcode: \(opcode.hex(syntaxParadigm: .assembly))"
    }

    public var disassembled: String {
        let addressingModeString = addressingMode.description
        let paddedAddressingMode = addressingModeString + String(repeating: " ", count: 10 - addressingModeString.count)
        return String(format: "\(mnemonic.rawValue.uppercased()) \(paddedAddressingMode)")
    }
}

extension Instruction {

    /// A valid instruction supplied for testing or preview purposes in consumer projects
    public static var noop: Instruction {
        return .init(opcode: 0xEA, mnemonic: .nop, addressingMode: .implied)
    }
}
