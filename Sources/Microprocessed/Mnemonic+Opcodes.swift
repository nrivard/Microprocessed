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

        // MARK: - Incremement
        static let ina: [UInt8] = [0x1A]
        static let inx: [UInt8] = [0xE8]
        static let iny: [UInt8] = [0xC8]
        static let inc: [UInt8] = [0xE6, 0xEE, 0xF6, 0xFE]

        // MARK: - Decrement
        static let dea: [UInt8] = [0x3A]
        static let dex: [UInt8] = [0xCA]
        static let dey: [UInt8] = [0x88]
        static let dec: [UInt8] = [0xC6, 0xCE, 0xD6, 0xDE]

        // MARK: - Shift
        static let asl: [UInt8] = [0x06, 0x0A, 0x0E, 0x16, 0x1E]
        static let lsr: [UInt8] = [0x46, 0x4A, 0x4E, 0x56, 0x5E]
        static let rol: [UInt8] = [0x26, 0x2A, 0x2E, 0x36, 0x3E]
        static let ror: [UInt8] = [0x66, 0x6A, 0x6E, 0x76, 0x7E]

        // MARK: - Logical Operations
        static let and: [UInt8] = [0x21, 0x25, 0x29, 0x2D, 0x31, 0x32, 0x35, 0x39, 0x3D]
        static let ora: [UInt8] = [0x01, 0x05, 0x09, 0x0D, 0x11, 0x12, 0x15, 0x19, 0x1D]
        static let eor: [UInt8] = [0x41, 0x45, 0x49, 0x4D, 0x51, 0x52, 0x55, 0x59, 0x5D]
        static let bit: [UInt8] = [0x24, 0x2C, 0x34, 0x3C, 0x89]

        // MARK: - Comparison
        static let cmp: [UInt8] = [0xC1, 0xC5, 0xC9, 0xCD, 0xD1, 0xD2, 0xD5, 0xD9, 0xDD]
        static let cpx: [UInt8] = [0xE0, 0xE4, 0xEC]
        static let cpy: [UInt8] = [0xC0, 0xC4, 0xCC]

        // MARK: - Test and Reset Bits
        static let trb: [UInt8] = [0x14, 0x1C]
        static let tsb: [UInt8] = [0x04, 0x0C]
        static let rmb: [UInt8] = [0x07, 0x17, 0x27, 0x37, 0x47, 0x57, 0x67, 0x77]
        static let smb: [UInt8] = [0x87, 0x97, 0xA7, 0xB7, 0xC7, 0xD7, 0xE7, 0xF7]

        // MARK: - Arithmetic
        static let adc: [UInt8] = [0x61, 0x65, 0x69, 0x6D, 0x71, 0x72, 0x75, 0x79, 0x7D]
        static let sbc: [UInt8] = [0xE1, 0xE5, 0xE9, 0xED, 0xF1, 0xF2, 0xF5, 0xF9, 0xFD]

        // MARK: - Jumps
        static let jmp: [UInt8] = [0x4C, 0x6C, 0x7C]
        static let jsr: [UInt8] = [0x20]
        static let rts: [UInt8] = [0x60]
        static let rti: [UInt8] = [0x40]

        // MARK: - Branches
        static let bra: [UInt8] = [0x80]
        static let beq: [UInt8] = [0xF0]
        static let bne: [UInt8] = [0xD0]
        static let bcc: [UInt8] = [0x90]
        static let bcs: [UInt8] = [0xB0]
        static let bvc: [UInt8] = [0x50]
        static let bvs: [UInt8] = [0x70]
        static let bmi: [UInt8] = [0x30]
        static let bpl: [UInt8] = [0x10]
        static let bbr: [UInt8] = [0x0F, 0x1F, 0x2F, 0x3F, 0x4F, 0x5F, 0x6F, 0x7F]
        static let bbs: [UInt8] = [0x8F, 0x9F, 0xAF, 0xBF, 0xCF, 0xDF, 0xEF, 0xFF]

        // MARK: - Processor Status
        static let clc: [UInt8] = [0x18]
        static let cld: [UInt8] = [0xD8]
        static let cli: [UInt8] = [0x58]
        static let clv: [UInt8] = [0xB8]
        static let sec: [UInt8] = [0x38]
        static let sed: [UInt8] = [0xF8]
        static let sei: [UInt8] = [0x78]

        // MARK: - Transfers
        static let tax: [UInt8] = [0xAA]
        static let tay: [UInt8] = [0xA8]
        static let txa: [UInt8] = [0x8A]
        static let tya: [UInt8] = [0x98]

        // MARK: - Miscellaneous
        static let noop: [UInt8] = [0xEA]
        static let brk: [UInt8] = [0x00]
    }
}
