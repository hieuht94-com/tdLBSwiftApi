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
        //            XCTAssertThrowsError
    }



    func testPlotDirIsCreated0() {

        let outDir = try! OutputDir(testRootDir)


        let plotDir = outDir.createPlotDir(testPlotDir[0])


        let testDir = testRootDir + "/" + testPlotDir[0]
        XCTAssert(fm.fileExists(atPath: testDir, isDirectory: &isDirectory))
        XCTAssertEqual(plotDir.path, testDir)
    }


    func testPlotDirIsCreated2(){
        let outDir = try! OutputDir(testRootDir)

        let plotDir = outDir.getXYPlane(atK: 10, step: 10)

        let testDir = testRootDir + "/" + testPlotDir[2]
        XCTAssert(fm.fileExists(atPath: testDir, isDirectory: &isDirectory))
        print("QQQQQQQ" + plotDir.path)
        XCTAssertEqual(plotDir.path, testDir)
    }




    //
    //        let QvecbinFile = plot.plotQvecBinFile(name: "plot_")
    //
    //        let step = plot.step()
    //        let version = plot.version()
    //
    //
    //        //Returns list of XYPLnaes files.
    //        let XYPlanes = o.getPlaneXYFiles(contents: steps)
    //
    //
    //        plot.savePPdim()
    //        ppDim.save(plot)




    func testJimmy(){
        XCTAssertEqual(formatStep(100), "00000100")
    }


    static var allTests = [
        ("testOutputDirInitWhenDirExists", testOutputDirInitWhenDirExists),
    ]
}
