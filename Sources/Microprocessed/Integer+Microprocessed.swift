//
//  File.swift
//  
//
//  Created by Nate Rivard on 30/06/2020.
//

import Foundation

extension UInt8 {

    var bcd: UInt8 {
        var shift = 0
        var digit = 0

        var copy = self
        var value: UInt8 = 0

        while copy > 0 {
            digit = Int(copy % 10)
            value += UInt8(digit << shift)
            shift += 4
            copy /= 10
        }

        return value
    }

    init(bcd: UInt8) {
        self = 10 * (bcd >> 4) + (0x0F & bcd)
    }
}

extension UInt16 {

    var truncated: UInt8 {
        return UInt8(0x00FF & self)
    }
}

public enum IntegerSyntaxParadigm {
    case assembly
    case c

    public func constantPrefix(radix: Int) -> String {
        switch (self, radix) {
        case (.assembly, 16):
            return "$"
        case (.assembly, 8):
            return "@"
        case (.assembly, 2):
            return "%"

        case (.c, 16):
            return "0x"
        case (.c, 8):
            return "0o"
        case (.c, 2):
            return "0b"

        case (_, _):
            return ""
        }
    }
}

extension FixedWidthInteger {

    public var hex: String {
        let hexString = String(self, radix: 16, uppercase: true)
        let zerosPrefix = String(repeating: "0", count: (MemoryLayout<Self>.size * 2) - hexString.count)
        return "0x\(zerosPrefix)\(hexString)"
    }

    public var bin: String {
        return "0b" + String(self, radix: 2, uppercase: true)
    }

    public func hex(syntaxParadigm: IntegerSyntaxParadigm = .c) -> String {
        let hexString = String(self, radix: 16, uppercase: true)
        let zerosPrefix = String(repeating: "0", count: (MemoryLayout<Self>.size * 2) - hexString.count)
        return "\(syntaxParadigm.constantPrefix(radix: 16))\(zerosPrefix)\(hexString)"
    }

//    public func
}
