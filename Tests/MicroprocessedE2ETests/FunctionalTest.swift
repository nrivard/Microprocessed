import XCTest
@testable import Microprocessed

final class FunctionalTests: End2EndTest {

    static let successTrapAddress: UInt16 = 0x3399

    override var filePath: String {
        return "Binaries/6502_functional_test"
    }

//    private let breakpoints: Set<UInt16> = [
//        successTrapAddress,
//        0x335F
//    ]

    func testRunFunctionalTests() throws {
        let testExp = self.expectation(description: "Running Klaus functional test suite")

        runQueue.async { [unowned self] in
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
