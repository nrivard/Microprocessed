@testable import Microprocessed

/// simple `MemoryAddressable` class that you can set up some test data in and it will read/write to
/// those addresses. Will return no-op (`0xEA`) for any reads that have not been set up
final class TestMemory: MemoryAddressable {

    var memory: [UInt16: UInt8] = [
        Microprocessor.resetVector: 0x00,
        Microprocessor.resetVectorHigh: 0x80
    ]

    func read(from address: UInt16) throws -> UInt8 {
        return memory[address] ?? 0xEA
    }

    func write(to address: UInt16, data: UInt8) throws {
        memory[address] = data
    }
}

extension MemoryAddressable {

    mutating func writeProgram(_ program: [UInt8], startingAtAddress pc: UInt16) throws {
        for (index, byte) in program.enumerated() {
            try write(to: pc + UInt16(index), data: byte)
        }
    }
}
