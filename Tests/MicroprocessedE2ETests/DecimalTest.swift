import XCTest
@testable import Microprocessed

final class DecimalTest: End2EndTest {

    override var filePath: String {
        return "Binaries/65C02_decimal_test"
    }

    func testRunDecimalTests() throws {
        let testExp = self.expectation(description: "Running Bruce Clark decimal mode test suite")

        runQueue.async { [unowned self] in
            // test requires PC be $0200
            mpu.registers.PC = 0x0200
            var shouldRun = true
            var pc: UInt16 = 0

            while shouldRun {
                pc = mpu.registers.PC

                do {
                    try mpu.tick()
                } catch {
                    XCTAssert(false, "Encountered error: \(error) at PC: \(pc.hex)")
                }

                shouldRun = mpu.runMode != .stopped
            }

            // check for success
            let error = try! ram.read(from: 0x0B)
            XCTAssert(error == 0, "Encountered an error at \(pc.hex)")
            testExp.fulfill()
        }

        waitForExpectations(timeout: 120)
    }
}
