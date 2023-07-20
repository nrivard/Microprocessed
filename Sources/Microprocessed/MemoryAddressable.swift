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
public protocol MemoryAddressable {

    /// return an 8 bit value for the given 16 bit address
    func read(from address: UInt16) throws -> UInt8

    /// write an 8 bit value to the given 16 bit address
    mutating func write(to address: UInt16, data: UInt8) throws
}

extension MemoryAddressable {

    /// reads a 16 bit value with low order byte at `lowByteAddress` and then a high order
    /// byte at `lowByteAddress + 1`
    ///
    /// TODO: this does not respect zero-page addressing wrapping so should be used with caution.
    public func readWord(fromAddressStartingAt lowByteAddress: UInt16) throws -> UInt16 {
        let highByteAddress = lowByteAddress + 1

        return UInt16(try read(from: lowByteAddress))
             | UInt16(try read(from: highByteAddress)) << 8
    }

    /// writes a 16 bit value with low order byte at `lowByteAddress` and then a high order
    /// byte at `lowByteAddress + 1`
    ///
    /// TODO: this does not respect zero-page addressing wrapping so should be used with caution.
    public mutating func write(toAddressStartingAt lowByteAddress: UInt16, word: UInt16) throws {
        let highByteAddress = lowByteAddress + 1

        let lowByte = UInt8(truncatingIfNeeded: word)
        let highByte = UInt8(truncatingIfNeeded: word >> 8)

        try write(to: lowByteAddress, data: lowByte)
        try write(to: highByteAddress, data: highByte)
    }
}


extension MemoryAddressable {

    public func dump(range: ClosedRange<UInt16> = 0...0xFF, lineLimit: UInt16 = 8) throws {
        let chunks = range.chunked(into: UInt16.Stride(lineLimit))

        for chunk in chunks {
            let line = try chunk.map { try read(from: $0).hex }.joined(separator: " ")
            print(line)
        }
    }
}

extension ClosedRange where Bound: FixedWidthInteger {

    public func chunked(into size: Bound.Stride) -> [[Bound]] {
        var chunks: [[Bound]] = []

        for lineStart in stride(from: lowerBound, to: upperBound, by: size) {
            let lineEnd = lineStart + Bound(size)
            let chunk = Array(lineStart..<lineEnd)
            chunks.append(chunk)
        }

        return chunks
    }
}
