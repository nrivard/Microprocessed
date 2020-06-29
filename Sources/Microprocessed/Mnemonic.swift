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
        case sta
        case stx
        case sty

        // MARK: - Miscellaneous
        case nop
        case undefined

        init(_ opcode: UInt8) {
            switch opcode {
            case Opcodes.lda:
                self = .lda
            case Opcodes.ldx:
                self = .ldx
            case Opcodes.ldy:
                self = .ldy

            case Opcodes.sta:
                self = .sta
            case Opcodes.stx:
                self = .stx
            case Opcodes.sty:
                self = .sty

            case Opcodes.noop:
                self = .nop

            default:
                self = .undefined
            }
        }
    }
}
