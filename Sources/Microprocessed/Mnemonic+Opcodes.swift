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

        // MARK: - Miscellaneous
        static let noop: [UInt8] = [0xEA]
    }
}
