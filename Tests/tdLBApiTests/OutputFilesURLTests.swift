import XCTest
@testable import tdLBApi

final class OutputFilesURLTests: XCTestCase {

    let fm = FileManager.default
    var testRootDir:String = ""
    var testPlotDir: [String] = []
    var isDirectory = ObjCBool(true)

    override func setUp() {
        super.setUp()
        testRootDir = fm.temporaryDirectory.path + "testDirIsCreated"
        testPlotDir = ["testPlotDir0", "testPlotDir1", "plot_vertical_axis.XYplane.V_4.Q_4.step_00000010.cut_10"]
        //Delete directories

    }




    func testOutputDirInitWhenDirExists() {
        let o = try! OutputDir(testRootDir)
        XCTAssertEqual(testRootDir, o.root.path)
    }

    func testOutputDirIsCreated() {
        let _ = try! OutputDir(testRootDir)
        XCTAssert(fm.fileExists(atPath: testRootDir))
        XCTAssert(fm.fileExists(atPath: testRootDir, isDirectory: &isDirectory))
    }

    func testOutputDirCannotBeCreatedDueToPermissions() {
        // TODO
        //            XCTAssertThrowsError
    }



    func testPlotDirIsCreated0() {

        let outDir = try! OutputDir(testRootDir)
        let plotDirString = outDir.formatXYPlane(QLength: 4, step: 10, atK:10)
        XCTAssertEqual(plotDirString, testPlotDir[2])


        let plotDir = outDir.createXYPlane(QLength: 4, step: 10, atK:10)
        XCTAssert(fm.fileExists(atPath: plotDir.path, isDirectory: &isDirectory))
    }





    static var allTests = [
        ("testOutputDirInitWhenDirExists", testOutputDirInitWhenDirExists),
    ]
}
