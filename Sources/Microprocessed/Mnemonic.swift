//
//  File.swift
//  
//
//  Created by Nate Rivard on 23/06/2020.
//

import Foundation

extension Instruction {

    public enum Mnemonic {

        // MARK: - Load
        case lda
        case ldx
        case ldy

        // MARK: - Store
        

        // MARK: - Miscellaneous
        case nop
        case undefined

        init(_ opcode: UInt8) {
            switch opcode {
            case 0xA1, 0xA5, 0xA9, 0xAD, 0xB1...0xB2, 0xB5, 0xB9, 0xBD:
                self = .lda
            case 0xA2, 0xA6, 0xAE, 0xB6, 0xBE:
                self = .ldx
            case 0xA0, 0xA4, 0xAC, 0xB4, 0xBC:
                self = .ldy
            case 0xEA:
                self = .nop
            default:
                self = .undefined
            }
        }
    }
}
