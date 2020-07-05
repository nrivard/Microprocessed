import XCTest
@testable import Microprocessed

final class CLCTests: SystemTests {

    func testCLC() throws {
        let opcode: UInt8 = 0x18

        mpu.registers.setCarry()
        XCTAssert(mpu.registers.$SR.contains(.didCarry))

        try mpu.execute(opcode)
        XCTAssertFalse(mpu.registers.$SR.contains(.didCarry))
    }
}
