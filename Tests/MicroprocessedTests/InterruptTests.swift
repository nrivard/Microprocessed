import XCTest
@testable import Microprocessed

final class InterruptTests: SystemTests {
    var interruptor = Interruptor()

    override var interruptors: [Interrupting] {
        return [interruptor]
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        try ram.write(toAddressStartingAt: Microprocessor.irqVector, word: 0xC000)
        try ram.write(toAddressStartingAt: Microprocessor.nmiVector, word: 0xD000)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        interruptor.interruptStatus = .none
    }

    func testIRQ() throws {
        /// irq handler that just calls RTI
        try ram.write(to: 0xC000, data: 0x40)
        XCTAssert(mpu.registers.PC == 0x8000)

        interruptor.interruptStatus = .maskable
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0xC000)
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0x8000)
        /// irq has not been de-asserted so we should re-enter irq handler
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0xC000)
        interruptor.interruptStatus = .none
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0x8000)
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)
    }

    func testNMI() throws {
        /// irq handler that just calls RTI
        try ram.write(to: 0xD000, data: 0x40)
        XCTAssert(mpu.registers.PC == 0x8000)

        interruptor.interruptStatus = .nonMaskable
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0xD000)
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0x8000)
        /// irq has not been de-asserted so we should re-enter irq handler
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0xD000)
        interruptor.interruptStatus = .none
        try mpu.tick()

        XCTAssert(mpu.registers.PC == 0x8000)
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)
    }

    func testNMISupercedesIRQ() throws {
        /// irq and nmi handlers just return
        try ram.write(to: 0xC000, data: 0x40)
        try ram.write(to: 0xD000, data: 0x40)
        XCTAssert(mpu.registers.PC == 0x8000)

        interruptor.interruptStatus = .maskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xC000)
        XCTAssert(mpu.interruptMask == [.irq])

        interruptor.interruptStatus = .nonMaskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xD000)
        XCTAssert(mpu.interruptMask == [.irq, .nmi])

        interruptor.interruptStatus = .none
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xC000)
        XCTAssert(mpu.interruptMask == [.irq])

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8000)
        XCTAssert(mpu.interruptMask == [])

        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)
    }

    func testIRQWithInterruptsDisabled() throws {
        mpu.registers.setInterruptsDisabled()
        XCTAssert(mpu.registers.PC == 0x8000)

        interruptor.interruptStatus = .maskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)

        mpu.registers.clearInterruptsDisabled()
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xC000)
    }

    func testNMIWithInterruptsDisabled() throws {
        mpu.registers.setInterruptsDisabled()
        XCTAssert(mpu.registers.PC == 0x8000)

        interruptor.interruptStatus = .nonMaskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xD000)
    }

    func testWakeOnInterrupt() throws {
        XCTAssert(mpu.registers.PC == 0x8000)

        /// execute `WAI`
        try mpu.execute(0xCB)
        XCTAssert(mpu.registers.PC == 0x8001)
        XCTAssert(mpu.runMode == .waitingForInterrupt)
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)

        interruptor.interruptStatus = .maskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0xC000)
        XCTAssert(mpu.runMode == .normal)
    }

    func testWakeOnInterruptWithInterruptsDisabled() throws {
        mpu.registers.setInterruptsDisabled()
        XCTAssert(mpu.registers.PC == 0x8000)

        /// execute `WAI`
        try mpu.execute(0xCB)
        XCTAssert(mpu.registers.PC == 0x8001)
        XCTAssert(mpu.runMode == .waitingForInterrupt)
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8001)

        interruptor.interruptStatus = .maskable
        try mpu.tick()
        XCTAssert(mpu.registers.PC == 0x8002)
        XCTAssert(mpu.runMode == .normal)
    }
}

/// simple interruptor that allows direct setting of interrupt status
final class Interruptor: Interrupting {
    var interruptStatus: InterruptStatus = .none
}
