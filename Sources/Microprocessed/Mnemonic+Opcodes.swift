//
//  File.swift
//  
//
//  Created by Nate Rivard on 25/06/2020.
//

import Foundation

extension Instruction.Mnemonic {

    enum Opcodes {
        // MARK: - Loading

        static let lda: [UInt8] = [0xA1, 0xA5, 0xA9, 0xAD, 0xB1, 0xB2, 0xB5, 0xB9, 0xBD]
        static let ldx: [UInt8] = [0xA2, 0xA6, 0xAE, 0xB6, 0xBE]
        static let ldy: [UInt8] = [0xA0, 0xA4, 0xAC, 0xB4, 0xBC]

        // MARK: - Storing
        static let sta: [UInt8] = [0x81, 0x85, 0x8D, 0x91, 0x92, 0x95, 0x99, 0x9D]
        static let stx: [UInt8] = [0x86, 0x8E, 0x96]
        static let sty: [UInt8] = [0x84, 0x8C, 0x94]
        static let stz: [UInt8] = [0x64, 0x74, 0x9C, 0x9E]

        // MARK: - Push Stack
        static let pha: [UInt8] = [0x48]
        static let phx: [UInt8] = [0xDA]
        static let phy: [UInt8] = [0x5A]
        static let php: [UInt8] = [0x08]

        // MARK: - Pop Stack
        static let pla: [UInt8] = [0x68]
        static let plx: [UInt8] = [0xFA]
        static let ply: [UInt8] = [0x7A]
        static let plp: [UInt8] = [0x28]

        // MARK: - Transfer Stack
        static let tsx: [UInt8] = [0xBA]
        static let txs: [UInt8] = [0x9A]

        // MARK: - Miscellaneous
        static let noop: [UInt8] = [0xEA]
    }
}
