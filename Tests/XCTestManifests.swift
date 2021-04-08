import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(tdLBApiTests.allTests),
        testCase(OutputFilesURLTests.allTests)

    ]
}
#endif
