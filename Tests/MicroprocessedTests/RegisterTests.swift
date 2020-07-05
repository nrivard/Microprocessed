import XCTest
@testable import Microprocessed

final class RegistersTest: XCTestCase {

    func testSetZero() {
        var registers = Registers()

        /// we haven't performed an arithmetic operation yet
        XCTAssertFalse(registers.$SR.contains(.isZero))

        registers.updateZero(for: 1)
        XCTAssertFalse(registers.$SR.contains(.isZero))

        registers.updateZero(for: 0)
        XCTAssert(registers.$SR.contains(.isZero))

        // test that it gets cleared now
        registers.updateZero(for: 1)
        XCTAssertFalse(registers.$SR.contains(.isZero))
    }

    func testSetIsNegative() {
        var registers = Registers()

        XCTAssertFalse(registers.$SR.contains(.isNegative))

        registers.updateSign(for: 0)
        XCTAssertFalse(registers.$SR.contains(.isNegative))

        registers.updateSign(for: 0xF0)
        XCTAssert(registers.$SR.contains(.isNegative))

        registers.updateSign(for: 0x01)
        XCTAssertFalse(registers.$SR.contains(.isNegative))

        // let's try and trick it using a signed Int8
        let newValue: Int8 = -1
        registers.updateSign(for: UInt16(UInt8(bitPattern: newValue)))
        XCTAssert(registers.$SR.contains(.isNegative))
    }

    func testSetDidCarry() {
        var registers = Registers()

        XCTAssertFalse(registers.$SR.contains(.didCarry))

        registers.updateCarry(for: 0)
        XCTAssertFalse(registers.$SR.contains(.didCarry))

        registers.updateCarry(for: 0xFF)
        XCTAssertFalse(registers.$SR.contains(.didCarry))

        registers.updateCarry(for: 0x100)
        XCTAssert(registers.$SR.contains(.didCarry))

        registers.updateCarry(for: 0x101)
        XCTAssert(registers.$SR.contains(.didCarry))

        registers.updateCarry(for: 0xFE)
        XCTAssertFalse(registers.$SR.contains(.didCarry))
    }

    func testSetDidOverflow() {
        var registers = Registers()

        XCTAssertFalse(registers.$SR.contains(.didOverflow))

        registers.updateOverflow(for: 0x0060, leftOperand: 0x0050, rightOperand: 0x0010)
        XCTAssertFalse(registers.$SR.contains(.didOverflow))

        // pos + pos -> neg
        registers.updateOverflow(for: 0x00A0, leftOperand: 0x0050, rightOperand: 0x0050)
        XCTAssert(registers.$SR.contains(.didOverflow))

        // unsigned carry but no signed overflow
        registers.updateOverflow(for: 0x0120, leftOperand: 0x50, rightOperand: 0xD0)
        XCTAssertFalse(registers.$SR.contains(.didOverflow))

        // neg + neg -> pos
        registers.updateOverflow(for: 0x0160, leftOperand: 0x00D0, rightOperand: 0x0090)
        XCTAssert(registers.$SR.contains(.didOverflow))
    }
}
