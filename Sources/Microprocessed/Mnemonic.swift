//
//  Mnemonic.swift
//  
//
//  Created by Nate Rivard on 23/06/2020.
//

import Foundation

extension Instruction {

    public enum Mnemonic: String, CaseIterable {

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
        case beq
        case bne
        case bcc
        case bcs
        case bvc
        case bvs
        case bmi
        case bpl
        case bbr
        case bbs

        // MARK: - Processor Status
        case clc
        case cld
        case cli
        case clv
        case sec
        case sed
        case sei

        // MARK: - Transfers
        case tax
        case tay
        case txa
        case tya

        // MARK: - Miscellaneous
        case nop
        case brk
        case stp
        case wai

        case unused
        case undefined

        // aliases for easy alignment in the opcode arrays
        static let unu: Mnemonic = .unused
        static let und: Mnemonic = .undefined

        static let opcodes: ContiguousArray<Instruction.Mnemonic> = [
          /* $x0   $x1   $x2   $x3   $x4   $x5   $x6   $x7   $x8   $x9   $xA   $xB   $xC   $xD   $xE   $xF  */
            .brk, .ora, .unu, .unu, .tsb, .ora, .asl, .rmb, .php, .ora, .asl, .unu, .tsb, .ora, .asl, .bbr, // $0x
            .bpl, .ora, .ora, .unu, .trb, .ora, .asl, .rmb, .clc, .ora, .ina, .unu, .trb, .ora, .asl, .bbr, // $1x
            .jsr, .and, .unu, .unu, .bit, .and, .rol, .rmb, .plp, .and, .rol, .unu, .bit, .and, .rol, .bbr, // $2x
            .bmi, .and, .and, .unu, .bit, .and, .rol, .rmb, .sec, .and, .dea, .unu, .bit, .and, .rol, .bbr, // $3x
            .rti, .eor, .unu, .unu, .unu, .eor, .lsr, .rmb, .pha, .eor, .lsr, .unu, .jmp, .eor, .lsr, .bbr, // $4x
            .bvc, .eor, .eor, .unu, .unu, .eor, .lsr, .rmb, .cli, .eor, .phy, .unu, .unu, .eor, .lsr, .bbr, // $5x
            .rts, .adc, .unu, .unu, .stz, .adc, .ror, .rmb, .pla, .adc, .ror, .unu, .jmp, .adc, .ror, .bbr, // $6x
            .bvs, .adc, .adc, .unu, .stz, .adc, .ror, .rmb, .sei, .adc, .ply, .unu, .jmp, .adc, .ror, .bbr, // $7x
            .bra, .sta, .unu, .unu, .sty, .sta, .stx, .smb, .dey, .bit, .txa, .unu, .sty, .sta, .stx, .bbs, // $8x
            .bcc, .sta, .sta, .unu, .sty, .sta, .stx, .smb, .tya, .sta, .txs, .unu, .stz, .sta, .stz, .bbs, // $9x
            .ldy, .lda, .ldx, .unu, .ldy, .lda, .ldx, .smb, .tay, .lda, .tax, .unu, .ldy, .lda, .ldx, .bbs, // $Ax
            .bcs, .lda, .lda, .unu, .ldy, .lda, .ldx, .smb, .clv, .lda, .tsx, .unu, .ldy, .lda, .ldx, .bbs, // $Bx
            .cpy, .cmp, .unu, .unu, .cpy, .cmp, .dec, .smb, .iny, .cmp, .dex, .wai, .cpy, .cmp, .dec, .bbs, // $Cx
            .bne, .cmp, .cmp, .unu, .unu, .cmp, .dec, .smb, .cld, .cmp, .phx, .stp, .unu, .cmp, .dec, .bbs, // $Dx
            .cpx, .sbc, .unu, .unu, .cpx, .sbc, .inc, .smb, .inx, .sbc, .nop, .unu, .cpx, .sbc, .inc, .bbs, // $Ex
            .beq, .sbc, .sbc, .unu, .unu, .sbc, .inc, .smb, .sed, .sbc, .plx, .unu, .unu, .sbc, .inc, .bbs, // $Fx
        ]

        init(_ opcode: UInt8) {
            self = Mnemonic.opcodes.withUnsafeBufferPointer { unsafePointer in
                return unsafePointer[Int(opcode)]
            }
        }
    }
}
