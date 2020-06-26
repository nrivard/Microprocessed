//
//  File.swift
//  
//
//  Created by Nate Rivard on 25/06/2020.
//

import Foundation

/// Register state of the `Microprocessor`
public struct Registers: Equatable, Hashable {
    
    /// accumulator
    var A: UInt8 = 0
    
    /// X index
    var X: UInt8 = 0
    
    /// Y index
    var Y: UInt8 = 0
    
    /// Stack pointer offset
    var SP: UInt8 = 0
    
    /// Status register
    var SR: UInt8 = 0
    
    /// Program counter
    var PC: UInt16 = 0
    
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
            SR |= StatusFlags.didCarry.rawValue
        } else {
            SR &= ~StatusFlags.didCarry.rawValue
        }
    }

    /// lifted from Mike Chamber's MoarNES and mathematically validated via
    /// http://www.righto.com/2012/12/the-6502-overflow-flag-explained.html
    mutating func updateOverflow(for result: UInt16, leftOperand: UInt8, rightOperand: UInt8) {
        if (result ^ UInt16(leftOperand)) & (result ^ UInt16(rightOperand)) & 0x0080 > 0 {
            SR |= StatusFlags.didOverflow.rawValue
        } else {
            SR &= ~StatusFlags.didOverflow.rawValue
        }
    }
}

extension Registers {

    /// ADC and SBC use temporary 16 bit values to do calculations. This is a convenience to save only the lower half of that value
    /// to the 8-bit A register
    mutating func saveAccumulator(with newValue: UInt16) {
        A = UInt8(newValue & 0x00FF)
    }
}

