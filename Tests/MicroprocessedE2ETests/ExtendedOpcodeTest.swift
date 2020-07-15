import XCTest
@testable import Microprocessed

final class ExtendedOpcodeTests: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    var runQueue = DispatchQueue(label: "Microprocessor", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)

    static let successTrapAddress: UInt16 = 0x3399

    private let breakpoints: Set<UInt16> = [
        0x072a
    ]

    enum Error: Swift.Error {
        case missingBinaryResource
        case infiniteLoopEncountered
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        // next, read in the program from a file and write to ram
        guard let path = Bundle.module.url(forResource: "65C02_extended_opcodes_test", withExtension: "bin") else {
            throw Error.missingBinaryResource
        }

        let data = try Data(contentsOf: path)
        let bytes: [UInt8] = .init(data)

        self.ram = ROMMemory(rom: bytes)
        self.mpu = Microprocessor(memoryLayout: ram)

        try mpu.reset()
    }

    func testRunExtendedOpcodesTests() throws {
        let testExp = self.expectation(description: "Running Klaus extended opcode test suite")

        runQueue.async { [self] in
            // test requires PC be $0400
            mpu.registers.PC = 0x0400
            var shouldRun = true

            /// the last 50 memory addresses and the instruction run there
            var instructions: [(UInt16, Instruction)] = []
            var instrCount = 0

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    let instr = try mpu.fetch()

                    if breakpoints.contains(pc) {
                        switch pc {
                        default:
                            break
                        }
                    }

                    instructions.append((pc, instr))
                    instructions = instructions.suffix(50)

                    try mpu.execute(instr)
                    instrCount += 1
                } catch {
                    XCTAssert(false, "Encountered error: \(error)")
                }

                if mpu.registers.PC == pc {
                    XCTAssert(pc == FunctionalTests.successTrapAddress, "Failure found at \(pc.hex)\nExecuted (NEW) \(instrCount) instructions")
                    testExp.fulfill()
                    shouldRun = false
                }
            }
        }

        waitForExpectations(timeout: 120)
    }
}
