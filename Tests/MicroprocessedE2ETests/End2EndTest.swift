import XCTest
@testable import Microprocessed

/// common test superclass for setting up a CPU, a binary file based `MemoryAddressable`, and an off main thread run queue.
/// Subclasses need to supply `filePath`, a `String` to the binary file
class End2EndTest: XCTestCase {

    var ram: MemoryAddressable!
    var mpu: Microprocessor!

    var runQueue = DispatchQueue(
        label: "Microprocessor",
        qos: .userInteractive,
        attributes: [],
        autoreleaseFrequency: .workItem
    )

    var filePath: String {
        fatalError("Test subclass must declare this property")
    }

    var breakpoints: Set<UInt16> = []

    enum Error: Swift.Error {
        case missingBinaryResource
    }

    override func setUpWithError() throws {
        try super.setUpWithError()

        // next, read in the program from a file and write to ram
        guard let path = Bundle.module.url(forResource: filePath, withExtension: "bin") else {
            throw Error.missingBinaryResource
        }

        let data = try Data(contentsOf: path)
        let bytes: [UInt8] = .init(data)

        self.ram = RAM(bytes)
        self.mpu = Microprocessor(memoryLayout: ram, configuration: .init(warnOnUnusedOpcodes: false))

        try mpu.reset()
    }
}
