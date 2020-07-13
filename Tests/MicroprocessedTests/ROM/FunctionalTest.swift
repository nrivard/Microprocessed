import XCTest
@testable import Microprocessed

final class FunctionalTests: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    var runQueue = DispatchQueue(label: "Microprocessor", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)

    static let successTrapAddress: UInt16 = 0x3399

    private let breakpoints: Set<UInt16> = [
        successTrapAddress,
//        0x35D1,
//        0x332B,
//        0x3328, // ; JSR to CHKDAD
//        0x36EC, // ; RTS from CHKDAD
//        0x3345, // ; BNE inner loop
        0x335F
    ]

    enum Error: Swift.Error {
        case missingBinaryResource
        case infiniteLoopEncountered
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        // next, read in the program from a file and write to ram
        guard let path = Bundle.module.url(forResource: "6502_functional_test", withExtension: "bin") else {
            throw Error.missingBinaryResource
        }

        let data = try Data(contentsOf: path)
        let bytes: [UInt8] = .init(data)

        self.ram = ROMMemory(rom: bytes)
        self.mpu = Microprocessor(memoryLayout: ram)

        try mpu.reset()
    }

    func testRunFunctionalTests() throws {
        let testExp = self.expectation(description: "Running Klaus functional test suite")

        runQueue.async { [self] in
            // test requires PC be $0400
            mpu.registers.PC = 0x336D // set to start of decimal tests for now
            var shouldRun = true
//            var start: Date = .init()

            /// the last 50 memory addresses and the instruction run there
            var instructions: [(UInt16, Instruction)] = []
            var instrCount = 0

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    let instr = try mpu.fetch()

                    if breakpoints.contains(pc) {
                        switch pc {
                        case 0x335F:
                            print("Outerloop BNE: \(mpu.registers.A)")
                        default:
                            break
                        }
                    }
//
                    instructions.append((pc, instr))
                    instructions = instructions.suffix(50)

                    try mpu.execute(instr)
                    instrCount += 1
                } catch {
                    XCTAssert(false, "Encountered error: \(error)")
                }

                if mpu.registers.PC == pc {
//                    print(Date().timeIntervalSince1970 - start.timeIntervalSince1970)
                    XCTAssert(pc == FunctionalTests.successTrapAddress, "Failure found at \(pc.hex)\nExecuted (NEW) \(instrCount) instructions")
                    testExp.fulfill()
                    shouldRun = false
                }
            }
        }

        waitForExpectations(timeout: 120)
    }
}

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
