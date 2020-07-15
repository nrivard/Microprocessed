import XCTest
@testable import Microprocessed

final class FunctionalTests: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    var runQueue = DispatchQueue(label: "Microprocessor", qos: .userInteractive, attributes: [], autoreleaseFrequency: .workItem)

    static let successTrapAddress: UInt16 = 0x3399

    private let breakpoints: Set<UInt16> = [
        successTrapAddress,
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
            mpu.registers.PC = 0x0400 // set to start of decimal tests for now
            var shouldRun = true

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    try mpu.tick()
                } catch {
                    XCTAssert(false, "Encountered error: \(error)")
                }

                if mpu.registers.PC == pc {
                    XCTAssert(pc == FunctionalTests.successTrapAddress, "Failure found at \(pc.hex)")
                    testExp.fulfill()
                    shouldRun = false
                }
            }
        }

        waitForExpectations(timeout: 120)
    }
}
