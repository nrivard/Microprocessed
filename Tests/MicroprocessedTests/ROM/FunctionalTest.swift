import XCTest
@testable import Microprocessed

final class FunctionalTests: SystemTests {

    static let successTrapAddress: UInt16 = 0x3399

    private let breakpoints: [UInt16] = [
        0x0670
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

        try ram.writeProgram(bytes, startingAtAddress: 0x00)
    }

    func testRunFunctionalTests() throws {
        let testExp = self.expectation(description: "Running Klaus functional test suite")

        DispatchQueue.global().async { [self] in
            // test requires PC be $0400
            mpu.registers.PC = 0x0400
            var shouldRun = true

            /// the last 50 memory addresses and the instruction run there
            var instructions: [(UInt16, Instruction)] = []

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    let instr = try mpu.fetch()

                    if breakpoints.contains(pc) {
                        print("BREAKPOINT")
                    }

                    instructions.append((pc, instr))
                    instructions = instructions.suffix(50)

                    try mpu.execute(instr)

                    if mpu.registers.PC == pc {
                        XCTAssert(pc == FunctionalTests.successTrapAddress, "Failure found at \(String(hex: pc))\nLast \(instructions.count) instructions: \(instructions)")
                        testExp.fulfill()
                        shouldRun = false
                    }
                } catch {
                    XCTAssert(false, "Encountered error: \(error)")
                }
            }
        }

        waitForExpectations(timeout: 30)
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
