import Microprocessed

/// simple `MemoryAddressable` class that you can set up some test data in and it will read/write to
/// those addresses. Will return no-op (`0xEA`) for any reads that have not been set up
final class TestMemory: MemoryAddressable {

    var memory: [UInt16: UInt8] = [:]

    func read(from address: UInt16) throws -> UInt8 {
        return memory[address] ?? 0xEA
    }

    func write(to address: UInt16, data: UInt8) throws {
        memory[address] = data
    }
}
