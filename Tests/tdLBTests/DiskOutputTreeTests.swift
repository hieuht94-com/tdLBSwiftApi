//
//  InputFilesV4URLTests.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 15/10/2019.
//

import XCTest
@testable import tdLB

class DiskOutputTreeTests: XCTestCase {

    let fm = FileManager.default
    var testRootDir: String = ""
    var testRootDirURL: URL!

    var isDirectory = ObjCBool(true)

    let testDirStrings = [
        "plot.XYplane.V5.step_00000010.cut_10",

        "plot.XZplane.V5.step_00000010.cut_10",
        "plot.XZplane.V5.step_00000010.cut_11",
        "plot.XZplane.V5.step_00000010.cut_12",
        "plot.XZplane.V5.step_00000020.cut_10",
        "plot.XZplane.V5.step_00000020.cut_11",
        "plot.XZplane.V5.step_00000020.cut_12",

        "plot.YZplane.V5.step_00000010.cut_10"
    ]
    var testDirURLs = [URL]()

    override func setUp() {
        super.setUp()
        testRootDir = fm.currentDirectoryPath + "/testRootDir"
        testRootDirURL = URL(fileURLWithPath: testRootDir, isDirectory: true)

        //Ensure testRootDir does not exist
        do {
            try fm.removeItem(at: URL(fileURLWithPath: testRootDir))
        } catch {
            //Item probably didnt exist
        }

        testDirURLs = testDirStrings.map { testRootDirURL.appendingPathComponent($0, isDirectory: true) }
    }

    override func tearDown() {
        super.tearDown()
        do {
            try fm.removeItem(at: URL(fileURLWithPath: testRootDir))
        } catch {
            //Some tests failed and Dir was not created
        }
    }

    func testDiskOutputTreeInitWhenDirExists() {
        let o = try! DiskOutputTree(rootDir: testRootDirURL)
        //TODO
        XCTAssert(o.dirExists(dir: testRootDirURL))
        XCTAssert(fm.fileExists(atPath: testRootDir))
        XCTAssert(fm.fileExists(atPath: testRootDir, isDirectory: &isDirectory))
    }

    func testDiskOutputTreeIsCreated() {
        _ = try! DiskOutputTree(rootDir: testRootDirURL, createDir: true)
        XCTAssert(fm.fileExists(atPath: testRootDir))
        XCTAssert(fm.fileExists(atPath: testRootDir, isDirectory: &isDirectory))
    }

    func testDiskOutputTreeCannotBeCreatedDueToPermissions() {
        // TODO
        //            XCTAssertThrowsError
        XCTAssertThrowsError(fm.fileExists(atPath: testRootDir))
        XCTAssertThrowsError(fm.fileExists(atPath: testRootDir, isDirectory: &isDirectory))
    }

}
