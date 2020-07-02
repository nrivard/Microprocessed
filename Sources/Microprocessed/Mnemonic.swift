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

        // MARK: - Increment
        case ina
        case inx
        case iny
        case inc

        // MARK: - Decrement
        case dea
        case dex
        case dey
        case dec

        // MARK: - Shift
        case asl
        case lsr
        case rol
        case ror

        // MARK: - Logical Operations
        case and
        case ora
        case eor
        case bit

        // MARK: - Comparison
        case cmp
        case cpx
        case cpy

        // MARK: - Test and Reset Bits
        case trb
        case tsb
        case rmb
        case smb

        // MARK: - Arithmetic
        case adc
        case sbc

        // MARK: - Jumps and Returns
        case jmp
        case jsr
        case rts
        case rti

        // MARK: - Branches
        case bra

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

            case Opcodes.ina:
                self = .ina
            case Opcodes.inx:
                self = .inx
            case Opcodes.iny:
                self = .iny
            case Opcodes.inc:
                self = .inc

            case Opcodes.dea:
                self = .dea
            case Opcodes.dex:
                self = .dex
            case Opcodes.dey:
                self = .dey
            case Opcodes.dec:
                self = .dec

            case Opcodes.asl:
                self = .asl
            case Opcodes.lsr:
                self = .lsr
            case Opcodes.rol:
                self = .rol
            case Opcodes.ror:
                self = .ror

            case Opcodes.and:
                self = .and
            case Opcodes.ora:
                self = .ora
            case Opcodes.eor:
                self = .eor
            case Opcodes.bit:
                self = .bit

            case Opcodes.cmp:
                self = .cmp
            case Opcodes.cpx:
                self = .cpx
            case Opcodes.cpy:
                self = .cpy

            case Opcodes.tsb:
                self = .tsb
            case Opcodes.trb:
                self = .trb
            case Opcodes.smb:
                self = .smb
            case Opcodes.rmb:
                self = .rmb

            case Opcodes.adc:
                self = .adc
            case Opcodes.sbc:
                self = .sbc

            case Opcodes.jmp:
                self = .jmp
            case Opcodes.jsr:
                self = .jsr
            case Opcodes.rts:
                self = .rts
            case Opcodes.rti:
                self = .rti

            case Opcodes.bra:
                self = .bra

            case Opcodes.noop:
                self = .nop

            default:
                self = .undefined
            }
        }
    }
}
