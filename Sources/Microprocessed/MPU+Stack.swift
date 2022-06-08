//
//  MPU+Stack.swift
//  
//
//  Created by Nate Rivard on 22/06/2020.
//

import Foundation

extension Microprocessor {

    public static let stackPointerBase: UInt16 = 0x0100
    public static let stackPointerEnd: UInt16 = 0x01FF

    func pop() throws -> UInt8 {
        registers.SP = registers.SP &+ 1
        return try memory.read(from: registers.$SP)
    }

    func push(_ value: UInt8) throws {
        try memory.write(to: registers.$SP, data: value)
        registers.SP = registers.SP &- 1
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

    func dumpStack() throws {
        for pointer in Microprocessor.stackPointerBase...(Microprocessor.stackPointerBase + 0xFF) {
            let prefix = pointer == registers.$SP ? "-->" : "   "
            let value = try memory.read(from: pointer)
            let address = pointer % 0x08 == 0 ? pointer.hex : ""
            print("\(prefix) [\(value.hex)]  \(address)")
        }
    }
}
