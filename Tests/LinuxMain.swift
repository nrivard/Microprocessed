import XCTest

import MicroprocessedTests
import MicroprocessedE2ETests

var tests = [XCTestCaseEntry]()
tests += MicroprocessedTests.allTests()
tests += MicroprocessedE2ETests.allTests()
XCTMain(tests)
