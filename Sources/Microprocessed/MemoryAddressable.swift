//
//  MemoryAddressable.swift
//  
//
//  Created by Nate Rivard on 18/06/2020.
//

import Foundation

/// protocol describing something that responds to memory requests, both reading and writing
///
/// To simulate your system, create an object that conforms to this protocol and responds
/// to memory requests
public protocol MemoryAddressable: AnyObject {

    /// return an 8 bit value for the given 16 bit address
    func read(from address: UInt16) throws -> UInt8

    /// write an 8 bit value to the given 16 bit address
    func write(to address: UInt16, data: UInt8) throws
}

extension MemoryAddressable {

    /// reads a 16 bit value with low order byte at `lowByteAddress` and then a high order
    /// byte at `lowByteAddress + 1`
    public func readWord(fromAddressStartingAt lowByteAddress: UInt16) throws -> UInt16 {
        let highByteAddress = lowByteAddress + 1

        return UInt16(try read(from: lowByteAddress))
             | UInt16(try read(from: highByteAddress)) << 8
    }

    /// writes a 16 bit value with low order byte at `lowByteAddress` and then a high order
    /// byte at `lowByteAddress + 1`
    public func write(toAddressStartingAt lowByteAddress: UInt16, word: UInt16) throws {
        let highByteAddress = lowByteAddress + 1

        let lowByte = UInt8(truncatingIfNeeded: word)
        let highByte = UInt8(truncatingIfNeeded: word >> 8)

        try write(to: lowByteAddress, data: lowByte)
        try write(to: highByteAddress, data: highByte)
    }
}
