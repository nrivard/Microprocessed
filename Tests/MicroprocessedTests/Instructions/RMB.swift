import XCTest
@testable import Microprocessed

final class RMBTests: SystemTests {

    func testRMB() throws {
        try ram.write(to: 0x10, data: 0xFF)

        /// 1 by 1, reset bits starting at LSB
        for index in 0..<8 {
            let opcode: UInt8 = UInt8(index << 4 | 0x07)
            try mpu.execute(opcode, data: 0x10)

            let expectedResult = UInt8(truncatingIfNeeded: 0xFF << (index + 1))
            XCTAssert(try ram.read(from: 0x0010) == expectedResult)
        }
    }
}
