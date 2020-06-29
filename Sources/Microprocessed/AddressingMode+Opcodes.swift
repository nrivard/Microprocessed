//
//  File.swift
//  
//
//  Created by Nate Rivard on 24/06/2020.
//

import Foundation

/// The canonical list of opcodes separated out into WDC65C02 categories
///
/// (https://www.mouser.co.uk/datasheet/2/436/w65c02s-2572.pdf)
extension Instruction.AddressingMode {

    enum Opcodes {
        // MARK: - Absolute

        /// a
        static let absolute: [UInt8] = [0x0C, 0x0D, 0x0E, 0x1C, 0x20, 0x2C, 0x2D, 0x2E, 0x4C, 0x4D, 0x4E, 0x6D, 0x6E, 0x8C, 0x8D, 0x8E, 0x9C, 0xAD, 0xAE,
                                        0xCC, 0xCD, 0xCE, 0xEC, 0xED, 0xEE]

        /// (a,x)
        static let absoluteIndexedIndirect: [UInt8] = [0x7C]

        /// a,x and a,y
        ///
        /// NOTE: indexed with X or Y
        static let absoluteIndexedX: [UInt8] = [0x1D, 0x1E, 0x3C, 0x3D, 0x3E, 0x5D, 0x5E, 0x7D, 0x7E, 0x9D, 0x9E, 0xBC, 0xBD, 0xDD, 0xDE, 0xFD, 0xFE]
        static let absoluteIndexedY: [UInt8] = [0x19, 0x39, 0x59, 0x79, 0x99, 0xB9, 0xBE, 0xD9, 0xF9]

        /// (a)
        static let absoluteIndrect: [UInt8] = [0x6C]

        // MARK: - Zero page

        /// zp
        static let zeroPage: [UInt8] = [0x04, 0x05, 0x06, 0x07, 0x14, 0x17, 0x24, 0x25, 0x26, 0x27, 0x37, 0x45, 0x46, 0x47, 0x57, 0x64, 0x65, 0x66, 0x67, 0x77,
                                        0x84, 0x85, 0x86, 0x87, 0x97, 0xA4, 0xA5, 0xA6, 0xA7, 0xB7, 0xC4, 0xC5, 0xC6, 0xC7, 0xD7, 0xE4, 0xE5, 0xE6, 0xE7, 0xF7]

        /// (zp, x)
        static let zeroPageIndexedIndirect: [UInt8] = [0x01, 0x21, 0x41, 0x61, 0x81, 0xA1, 0xC1, 0xE1]

        /// zp,x and zp,y
        static let zeroPageIndexedX: [UInt8] = [0x15, 0x16, 0x34, 0x35, 0x36, 0x55, 0x56, 0x74, 0x75, 0x76, 0x94, 0x95, 0xB4, 0xB5, 0xD5, 0xD6, 0xF5, 0xF6]
        static let zeroPageIndexedY: [UInt8] = [0x96, 0xB6]

        /// (zp)
        static let zeroPageIndirect: [UInt8] = [0x12, 0x32, 0x52, 0x72, 0x92, 0xB2, 0xD2, 0xF2]

        /// (zp),y
        static let zeroPageIndirectIndexed: [UInt8] = [0x11, 0x31, 0x51, 0x71, 0x91, 0xB1, 0xD1, 0xF1]

        // MARK: - Operandless

        /// A
        static let accumulator: [UInt8] = [0x0A, 0x1A, 0x2A, 0x3A, 0x4A, 0x6A, 0xAC]

        /// i
        static let implied: [UInt8] = [0x18, 0x38, 0x58, 0x78, 0x88, 0x8A, 0x98, 0x9A, 0xA8, 0xAA, 0xB8, 0xBA, 0xC8, 0xCA, 0xCB, 0xD8, 0xDB, 0xE8, 0xEA,
                                       0xF8]

        /// s
        static let stack: [UInt8] = [0x00, 0x08, 0x28, 0x40, 0x48, 0x5A, 0x60, 0x68, 0x7A, 0xDA, 0xFA]

        // MARK: - Other

        /// #
        static let immediate: [UInt8] = [0x09, 0x29, 0x49, 0x69, 0x89, 0xA0, 0xA2, 0xA9, 0xC0, 0xC9, 0xE0, 0xE9]

        /// r
        static let relative: [UInt8] = [0x0F, 0x10, 0x1F, 0x2F, 0x30, 0x3F, 0x4F, 0x50, 0x5F, 0x6F, 0x70, 0x7F, 0x80, 0x8F, 0x90, 0x9F, 0xAF, 0xB0, 0xBF,
                                        0xCF, 0xD0, 0xDF, 0xEF, 0xF0, 0xFF]

        // MARK: - UNUSED

        /// unused (or unknown) but should be treated as implied
        static let unused: [UInt8] = [0x02, 0x03, 0x0B, 0x13, 0x1B, 0x22, 0x23, 0x2B, 0x33, 0x3B, 0x42, 0x43, 0x44, 0x4B, 0x53, 0x54, 0x5B, 0x5C, 0x62, 0x63,
                                      0x6B, 0x73, 0x7B, 0x82, 0x83, 0x8B, 0x93, 0x9B, 0xA3, 0xAB, 0xB3, 0xBB, 0xC2, 0xC3, 0xD3, 0xD4, 0xDC, 0xE2, 0xE3, 0xEB,
                                      0xF3, 0xF4, 0xFB, 0xFC]
    }
}
