//
//  File.swift
//  
//
//  Created by Nate Rivard on 16/07/2020.
//

import Microprocessed

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
