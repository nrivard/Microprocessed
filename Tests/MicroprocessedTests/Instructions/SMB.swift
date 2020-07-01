import XCTest
@testable import Microprocessed

final class SMBTests: SystemTests {

    func testSMB() throws {
        try ram.write(to: 0x10, data: 0x00)

        /// 1 by 1, reset bits starting at LSB
        var expectedResult: UInt8 = 0x00
        for index in (0..<8) {
            let opcode: UInt8 = UInt8((0x08 + index) << 4 | 0x07)

            try mpu.execute(opcode, data: 0x10)

            expectedResult = (expectedResult << 1) | 0x1
            XCTAssert(try ram.read(from: 0x0010) == expectedResult)
        }
    }
}
