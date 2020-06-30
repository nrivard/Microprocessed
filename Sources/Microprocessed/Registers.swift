//
//  Registers.swift
//  
//
//  Created by Nate Rivard on 25/06/2020.
//

import Foundation

/// Register state of the `Microprocessor`
public struct Registers: Equatable, Hashable {
    
    /// accumulator
    public var A: UInt8 = 0
    
    /// X index
    public var X: UInt8 = 0
    
    /// Y index
    public var Y: UInt8 = 0
    
    /// Stack pointer offset
    public var SP: UInt8 = 0
    
    /// Status register
    public var SR: UInt8 = 0
    
    /// Program counter
    public var PC: UInt16 = 0
}

extension Registers {

    /// nicer interface into the status register that can be easily queried
    public var statusFlags: StatusFlags {
        return .init(rawValue: SR)
    }
}

extension Registers {

    mutating func updateZero(for result: UInt16) {
        if result & 0x00FF > 0 {
            SR &= ~StatusFlags.isZero.rawValue
        } else {
            SR |= StatusFlags.isZero.rawValue
        }
    }

    mutating func updateSign(for result: UInt16) {
        if result & 0x80 > 0 {
            SR |= StatusFlags.isNegative.rawValue
        } else {
            SR &= ~StatusFlags.isNegative.rawValue
        }
    }

    mutating func updateCarry(for result: UInt16) {
        if result & 0xFF00 > 0 {
            setCarry()
        } else {
            clearCarry()
        }
    }

    /// lifted from Mike Chamber's MoarNES and mathematically validated via http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    mutating func updateOverflow(for result: UInt16, leftOperand: UInt8, rightOperand: UInt8) {
        if (result ^ UInt16(leftOperand)) & (result ^ UInt16(rightOperand)) & 0x0080 > 0 {
            SR |= StatusFlags.didOverflow.rawValue
        } else {
            SR &= ~StatusFlags.didOverflow.rawValue
        }
    }
}

extension Registers {

    mutating func setCarry() {
        SR |= StatusFlags.didCarry.rawValue
    }

    mutating func clearCarry() {
        SR &= ~StatusFlags.didCarry.rawValue
    }
}
