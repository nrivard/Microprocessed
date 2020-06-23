//
//  File.swift
//  
//
//  Created by Nate Rivard on 22/06/2020.
//

import Foundation

extension Microprocessor {

    public static let stackPointerBase: UInt16 = 0x0100

    func pop() throws -> UInt8 {
        registers.SP += 1 // TODO: wrapping around?

        return try memory.read(from: stackPointerAddress)
    }

    func push(_ value: UInt8) throws {
        try memory.write(to: stackPointerAddress, data: value)
        registers.SP -= 1 // TODO: wrapping around?
    }
}

extension Microprocessor {

    func popWord() throws -> UInt16 {
        let lowByte = try pop()
        let highByte = try pop()

        return UInt16(lowByte) | (UInt16(highByte) << 8)
    }

    func pushWord(_ word: UInt16) throws {
        let lowByte = UInt8(truncatingIfNeeded: word)
        let highByte = UInt8(truncatingIfNeeded: word >> 8)

        try push(highByte)
        try push(lowByte)
    }
}

extension Microprocessor {

    var stackPointerAddress: UInt16 {
        return Microprocessor.stackPointerBase + UInt16(registers.SP)
    }
}
