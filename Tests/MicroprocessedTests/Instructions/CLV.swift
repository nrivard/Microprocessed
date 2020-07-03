import XCTest
@testable import Microprocessed

final class CLVTests: SystemTests {

    func testCLV() throws {
        let opcode: UInt8 = 0xB8

        mpu.registers.setOverflow()
        XCTAssert(mpu.registers.statusFlags.contains(.didOverflow))

        try mpu.execute(opcode)
        XCTAssertFalse(mpu.registers.statusFlags.contains(.didOverflow))
    }
}
