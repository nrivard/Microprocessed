//
//  File.swift
//  
//
//  Created by Nate Rivard on 25/06/2020.
//

import Foundation

public struct StatusFlags: OptionSet {
    public let rawValue: UInt8

    /// arithmetic operation resulted in a negative value
    public static let isNegative: StatusFlags = .init(rawValue: 1 << 7)

    /// signed arithmetic operation overflowed
    public static let didOverflow: StatusFlags = .init(rawValue: 1 << 6)

    /// This is simply always set. Don't use this!
    public static let alwaysSet: StatusFlags = .init(rawValue: 1 << 5)

    /// interrupt requested is a `BRK` when set. It is `IRQ` or `NMI` when not set
    public static let isSoftwareInterrupt: StatusFlags = .init(rawValue: 1 << 4)

    /// MPU is currently in decimal arithmetic mode
    public static let decimalMode: StatusFlags = .init(rawValue: 1 << 3)

    /// interrupts are currently disabled
    public static let interruptsDisabled: StatusFlags = .init(rawValue: 1 << 2)

    /// arithmetic operation resulted in a zero value
    public static let isZero: StatusFlags = .init(rawValue: 1 << 1)

    /// arithmetic operation resulted in a carry
    ///
    /// Ex: LSR would set this flag if bit `0` was a `1`. ASL would set this flag if bit `7` was a `1`.
    public static let didCarry: StatusFlags = .init(rawValue: 1 << 0)

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

extension StatusFlags {

    func updateZero(for value: UInt8) {
        
    }
}
