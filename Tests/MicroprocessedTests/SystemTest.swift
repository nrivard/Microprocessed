import XCTest
@testable import Microprocessed

class SystemTests: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.ram = TestMemory()
        self.mpu = Microprocessor(memoryLayout: ram)

        try mpu.reset()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        ram = nil
        mpu = nil
    }

    func reset(toAddress address: UInt16) throws {
        try ram.write(toAddressStartingAt: Microprocessor.resetVector, word: address)
        try mpu.reset()
    }
}

extension SystemTests {

    func runBranchTest(opcode: UInt8, notTakenCondition: @autoclosure () throws -> Void, takenCondition: @autoclosure () throws -> Void) throws {
        let offsets: [Int8] = [0x03, -0x07, 0x7F]

        let instrRunner: (UInt8, UInt8) throws -> UInt16 = {
            try self.setupBranchTest(opcode: $0, offset: $1)
            let instr = try self.mpu.fetch()
            try self.mpu.execute(instr)

            return instr.size
        }

        for offset in offsets {
            let unsignedOffset = UInt8(bitPattern: offset)
            var originalPC = mpu.registers.PC

            try notTakenCondition()

            var instrSize = try instrRunner(opcode, unsignedOffset)
            XCTAssert(mpu.registers.PC == originalPC + instrSize)

            originalPC = mpu.registers.PC
            try takenCondition()

            instrSize = try instrRunner(opcode, unsignedOffset)
            let expectedPC = UInt16(Int32(originalPC) + Int32(offset)) + instrSize
            XCTAssert(mpu.registers.PC == expectedPC, String(format: "Expected %X, got %X", expectedPC, mpu.registers.PC))
        }
    }

    /// override point to set up a branch test, but not execute it. the default implementation writes a 2 byte relative addr instruction
    func setupBranchTest(opcode: UInt8, offset: UInt8) throws {
        try mpu.writeOpcode(opcode, data: offset)
    }
}
