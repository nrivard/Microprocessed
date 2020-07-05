import XCTest
@testable import Microprocessed

final class CLVTests: SystemTests {

    func testCLV() throws {
        let opcode: UInt8 = 0xB8

        mpu.registers.setOverflow()
        XCTAssert(mpu.registers.$SR.contains(.didOverflow))

        try mpu.execute(opcode)
        XCTAssertFalse(mpu.registers.$SR.contains(.didOverflow))
    }
}
