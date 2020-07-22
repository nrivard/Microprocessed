import XCTest
@testable import Microprocessed

final class ExtendedOpcodeTests: End2EndTest {

    static let successTrapAddress: UInt16 = 0x24F1

    override var filePath: String {
        return "Binaries/65C02_extended_opcodes_test"
    }

    func testRunExtendedOpcodesTests() throws {
        let testExp = self.expectation(description: "Running Klaus extended opcode test suite")

        runQueue.async { [unowned self] in
            // test requires PC be $0400
            mpu.registers.PC = 0x0400
            var shouldRun = true

            var instrCount = 0

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    try mpu.tick()
                    instrCount += 1
                } catch {
                    XCTAssert(false, "Encountered error: \(error)")
                }

                if mpu.registers.PC == pc {
                    XCTAssert(pc == ExtendedOpcodeTests.successTrapAddress, "Failure found at \(pc.hex)\nExecuted \(instrCount) instructions")
                    testExp.fulfill()
                    shouldRun = false
                }
            }
        }

        waitForExpectations(timeout: 120)
    }
}
