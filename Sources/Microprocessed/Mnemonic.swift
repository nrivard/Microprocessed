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
        case stz

        // MARK: - Push Stack
        case pha
        case phx
        case phy
        case php

        // MARK: - Pull Stack
        case pla
        case plx
        case ply
        case plp

        // MARK: - Transfer Stack
        case tsx
        case txs

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
            case Opcodes.stz:
                self = .stz

            case Opcodes.pha:
                self = .pha
            case Opcodes.phx:
                self = .phx
            case Opcodes.phy:
                self = .phy
            case Opcodes.php:
                self = .php

            case Opcodes.pla:
                self = .pla
            case Opcodes.plx:
                self = .plx
            case Opcodes.ply:
                self = .ply
            case Opcodes.plp:
                self = .plp

            case Opcodes.tsx:
                self = .tsx
            case Opcodes.txs:
                self = .txs

            case Opcodes.noop:
                self = .nop

            default:
                self = .undefined
            }
        }
    }
}
