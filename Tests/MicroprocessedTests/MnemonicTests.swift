import XCTest
@testable import Microprocessed

typealias Mnemonic = Instruction.Mnemonic

final class MnemonicTests: XCTestCase {

    func testLDA() {
        XCTAssert(Mnemonic(0xA1) ~= .lda)
        XCTAssert(Mnemonic(0xA5) ~= .lda)
        XCTAssert(Mnemonic(0xA9) ~= .lda)
        XCTAssert(Mnemonic(0xAD) ~= .lda)
        XCTAssert(Mnemonic(0xB1) ~= .lda)
        XCTAssert(Mnemonic(0xB2) ~= .lda)
        XCTAssert(Mnemonic(0xB9) ~= .lda)
        XCTAssert(Mnemonic(0xBD) ~= .lda)
    }

    func testLDX() {
        XCTAssert(Mnemonic(0xA2) ~= .ldx)
        XCTAssert(Mnemonic(0xA6) ~= .ldx)
        XCTAssert(Mnemonic(0xAE) ~= .ldx)
        XCTAssert(Mnemonic(0xB6) ~= .ldx)
        XCTAssert(Mnemonic(0xBE) ~= .ldx)
    }

    func testLDY() {
        XCTAssert(Mnemonic(0xA0) ~= .ldy)
        XCTAssert(Mnemonic(0xA4) ~= .ldy)
        XCTAssert(Mnemonic(0xAC) ~= .ldy)
        XCTAssert(Mnemonic(0xB4) ~= .ldy)
        XCTAssert(Mnemonic(0xBC) ~= .ldy)
    }

    func testNOP() {
        XCTAssert(Mnemonic(0xEA) ~= .nop)
    }

    func testUndefined() {
        XCTAssert(Mnemonic(0x02) ~= .undefined)
    }
}
