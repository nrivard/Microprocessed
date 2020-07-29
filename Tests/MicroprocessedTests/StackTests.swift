import XCTest
@testable import Microprocessed

final class StackTests: SystemTests {

    func testStackPointerAddress() {
        XCTAssert(mpu.registers.$SP == 0x1FF)

        mpu.registers.SP = 0x01
        XCTAssert(mpu.registers.$SP == 0x101)
    }

    func testPush() throws {
        XCTAssert(mpu.registers.$SP == 0x1FF)

        try mpu.push(0x01)

        XCTAssert(mpu.registers.$SP == 0x1FE)
        XCTAssert(try ram.read(from: 0x1FF) == 0x01)
    }

    func testPop() throws {
        mpu.registers.SP = 0x00

        try ram.write(to: 0x101, data: 0x01)

        let value = try mpu.pop()
        XCTAssert(value == 0x01)
        XCTAssert(mpu.registers.$SP == 0x101)
    }

    func testPushWord() throws {
        XCTAssert(mpu.registers.$SP == 0x1FF)

        try mpu.pushWord(0xBEEF)
        XCTAssert(mpu.registers.$SP == 0x1FD)
        XCTAssert(try ram.read(from: 0x1FF) == 0xBE)
        XCTAssert(try ram.read(from: 0x1FE) == 0xEF)
    }

    func testPopWord() throws {
        mpu.registers.SP = 0x00

        try ram.write(to: 0x102, data: 0xBE)
        try ram.write(to: 0x101, data: 0xEF)

        let word = try mpu.popWord()
        XCTAssert(mpu.registers.$SP == 0x102)
        XCTAssert(word == 0xBEEF)
    }
}
