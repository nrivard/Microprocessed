import XCTest
@testable import Microprocessed

final class RTITests: SystemTests {

    func testRTI() throws {
        let opcode: UInt8 = 0x40
        let returnAddress: UInt16 = 0xA5DF
        let restoredSR: StatusFlags = [.isNegative, .didOverflow, .didCarry, .alwaysSet]

        // Given: this stack layout
        try mpu.pushWord(returnAddress)
        try mpu.push(restoredSR.rawValue)

        try mpu.execute(opcode)
        XCTAssert(mpu.registers.PC == returnAddress)
        XCTAssert(mpu.registers.$SR == restoredSR.union(.isSoftwareInterrupt))
    }
}
