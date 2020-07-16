import XCTest
@testable import Microprocessed

final class DecimalTest: End2EndTest {

    override var filePath: String {
        return "65C02_decimal_test"
    }

    func testRunDecimalTests() throws {
        let testExp = self.expectation(description: "Running Bruce Clark decimal mode test suite")

        runQueue.async { [unowned self] in
            // test requires PC be $0200
            mpu.registers.PC = 0x0200
            var shouldRun = true
            var instructions: [(String, Instruction)] = []

            while shouldRun {
                let pc = mpu.registers.PC

                do {
                    let instr = try mpu.fetch()
                    try mpu.execute(instr)

                    instructions.append((pc.hex, instr))
                } catch {
                    XCTAssert(false, "Encountered error: \(error) at PC: \(pc.hex)")
                }

                shouldRun = mpu.runMode != .stopped
            }

            // check for success
            let error = try! ram.read(from: 0x0B)
            XCTAssert(error == 0, "Encountered an error\n\(instructions.reduce("", { $0 + "\n\($1)" }))")
            testExp.fulfill()
        }

        waitForExpectations(timeout: 60)
    }
}
