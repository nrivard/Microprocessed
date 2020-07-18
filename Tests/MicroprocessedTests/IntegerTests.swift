import XCTest
@testable import Microprocessed

final class IntegerTests: XCTestCase {

    func testBCDConversion() throws {
        let dec: UInt8 = 96
        let bcd = dec.bcd
        XCTAssert(bcd == 0b10010110)

        XCTAssert((0 as UInt8).bcd == 0)
    }

    func testDECConversion() throws {
        let bcd: UInt8 = 0b10010110
        let dec = UInt8(bcd: bcd)
        XCTAssert(dec == 96)

        XCTAssert(UInt8(bcd: 0) == 0)
    }
}
