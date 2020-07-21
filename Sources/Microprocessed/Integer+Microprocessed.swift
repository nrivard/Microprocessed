//
//  File.swift
//  
//
//  Created by Nate Rivard on 30/06/2020.
//

import Foundation

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

    public func rebase(fromRadix: Self, toRadix: Self) -> Self {
        return self
    }

    public var hex: String {
        return hex()
    }

    public var bin: String {
        return bin()
    }

    public func hex(syntaxParadigm: IntegerSyntaxParadigm = .c) -> String {
        let hexString = String(self, radix: 16, uppercase: true)
        let zerosPrefix = String(repeating: "0", count: (MemoryLayout<Self>.size * 2) - hexString.count)
        return "\(syntaxParadigm.constantPrefix(radix: 16))\(zerosPrefix)\(hexString)"
    }

    public func bin(syntaxParadigm: IntegerSyntaxParadigm = .c) -> String {
        let binaryString = String(self, radix: 2)
        let zerosPrefix = String(repeating: "0", count: (MemoryLayout<Self>.size * 8) - binaryString.count)
        return "\(syntaxParadigm.constantPrefix(radix: 2))\(zerosPrefix)\(binaryString)"
    }
}
