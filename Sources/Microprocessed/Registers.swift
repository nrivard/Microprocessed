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
    @HardwareStatusFlags public var SR: UInt8 = 0
    
    /// Program counter
    public var PC: UInt16 = 0
}

extension Registers {

    mutating func updateZero(for result: UInt16) {
        if result & 0x00FF > 0 {
            clearZero()
        } else {
            setZero()
        }
    }

    mutating func updateSign(for result: UInt16) {
        if result & 0x80 > 0 {
            setIsNegative()
        } else {
            clearIsNegative()
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
            setOverflow()
        } else {
            clearOverflow()
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

    mutating func setZero() {
        SR |= StatusFlags.isZero.rawValue
    }

    mutating func clearZero() {
        SR &= ~StatusFlags.isZero.rawValue
    }

    mutating func setOverflow() {
        SR |= StatusFlags.didOverflow.rawValue
    }

    mutating func clearOverflow() {
        SR &= ~StatusFlags.didOverflow.rawValue
    }

    mutating func setIsNegative() {
        SR |= StatusFlags.isNegative.rawValue
    }

    mutating func clearIsNegative() {
        SR &= ~StatusFlags.isNegative.rawValue
    }

    mutating func setInterruptsDisabled() {
        SR |= StatusFlags.interruptsDisabled.rawValue
    }

    mutating func clearInterruptsDisabled() {
        SR &= ~StatusFlags.interruptsDisabled.rawValue
    }

    mutating func setDecimal() {
        SR |= StatusFlags.decimalMode.rawValue
    }

    mutating func clearDecimal() {
        SR &= ~StatusFlags.decimalMode.rawValue
    }

    mutating func clearSoftwareInterrupt() {
        SR &= ~StatusFlags.isSoftwareInterrupt.rawValue
    }
}

extension Registers {

    var arithmeticCarry: UInt8 {
        return (SR & StatusFlags.didCarry.rawValue) > 0 ? 1 : 0
    }
}

extension Registers: CustomStringConvertible {

    public var description: String {
        return """
            Registers:
              A: \(A.hex)
              X: \(X.hex)
              Y: \(Y.hex)
              SP: \(SP.hex)
              SR: \(SR.bin)
              PC: \(PC.hex)
            """
    }
}

/// Wraps the underlying value at the hardware level. This will always return `alwaysSet` and `isSoftwareInterrupt` as those
/// can only be something else on the stack, never at the hardware level
@propertyWrapper
public struct HardwareStatusFlags: Equatable, Hashable {

    private var status: UInt8
    private var flags: StatusFlags

    public var wrappedValue: UInt8 {
        get {
            return status
        } set {
            self.status = newValue | StatusFlags.alwaysSet.rawValue | StatusFlags.isSoftwareInterrupt.rawValue
            self.flags = StatusFlags(rawValue: self.status)
        }
    }

    public var projectedValue: StatusFlags {
        return flags
    }

    public init(wrappedValue: UInt8) {
        let value = wrappedValue | StatusFlags.alwaysSet.rawValue | StatusFlags.isSoftwareInterrupt.rawValue

        self.status = value
        self.flags = StatusFlags(rawValue: value)
    }
}
