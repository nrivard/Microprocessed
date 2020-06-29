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

        // MARK: - Miscellaneous
        static let noop: [UInt8] = [0xEA]
    }
}
