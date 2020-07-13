import XCTest
@testable import Microprocessed

final class BRKTests: SystemTests {

    func testBRK() throws {
        let returnAddress = mpu.registers.PC + 2
        let irqAddress: UInt16 = 0xA5DF
        let status: StatusFlags = [.isNegative, .didCarry, .didOverflow, .alwaysSet, .isSoftwareInterrupt]
        try ram.write(toAddressStartingAt: Microprocessor.irqVector, word: irqAddress)
        mpu.registers.SR = status.rawValue

        try mpu.execute(0x00)
        XCTAssert(mpu.registers.PC == irqAddress)
        XCTAssert(mpu.registers.$SR.contains(.interruptsDisabled))
        XCTAssert(try mpu.pop() == status.rawValue)
        XCTAssert(try mpu.popWord() == returnAddress)
    }
}
