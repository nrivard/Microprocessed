//
//  File.swift
//  
//
//  Created by Nate Rivard on 13/07/2020.
//

import Microprocessed

final class ROMMemory: MemoryAddressable {

    private var rom: [UInt8]

    init(rom: [UInt8]) {
        self.rom = rom
    }

    func read(from address: UInt16) throws -> UInt8 {
        return rom[Int(address)]
    }

    func write(to address: UInt16, data: UInt8) throws {
        rom[Int(address)] = data
    }
}
