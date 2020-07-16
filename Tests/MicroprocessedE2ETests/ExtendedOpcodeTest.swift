import XCTest
@testable import Microprocessed

final class ExtendedOpcodeTests: End2EndTest {

    // TODO: i very much doubt this is the real success trap address...
    static let successTrapAddress: UInt16 = 0x3399

//    private let breakpoints: Set<UInt16> = [
//        0x072a
//    ]

    override var filePath: String {
        return "65C02_extended_opcodes_test"
    }

    func testRunExtendedOpcodesTests() throws {
        let testExp = self.expectation(description: "Running Klaus extended opcode test suite")

        runQueue.async { [unowned self] in
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
