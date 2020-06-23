import XCTest
@testable import Microprocessed

class SystemTests: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    override func setUpWithError() throws {
        try super.setUpWithError()

        self.ram = TestMemory()
        self.mpu = Microprocessor(memoryLayout: ram)

        try mpu.reset()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        ram = nil
        mpu = nil
    }
}
