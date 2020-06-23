//
//  File.swift
//  
//
//  Created by Nate Rivard on 23/06/2020.
//

import Foundation

public struct Instruction {

    public let opcode: UInt8

    public var mnemonic: Mnemonic {
        return Mnemonic(opcode)
    }

    public init(_ opcode: UInt8) throws {
        self.opcode = opcode
    }
}
