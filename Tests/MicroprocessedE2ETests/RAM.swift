//
//  File.swift
//  
//
//  Created by Nate Rivard on 13/07/2020.
//

import Microprocessed

/// very simple read/write memory structure
final class RAM: MemoryAddressable {

    private var bytes: [UInt8]

    init(_ bytes: [UInt8]) {
        self.bytes = bytes
    }

    func read(from address: UInt16) throws -> UInt8 {
        if address < bytes.count {
            return bytes[Int(address)]
        } else {
            return 0xEA
        }
    }

    func write(to address: UInt16, data: UInt8) throws {
        bytes[Int(address)] = data
    }
}
