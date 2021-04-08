//
//  DiskOutputTree.swift
//  tdLBQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation

public enum diskErrors: Error {
    case fileNotFound
    case directoryNotFound
    case fileNotReadable
    case fileNotJsonParsable
    case isPlotDir
    case isNotPlotDir
    case otherDiskError
}

public enum OrthoPlaneOrientation {
    case xyPlane
    case xzPlane
    case yzPlane
}

public enum PlotDirKind: CaseIterable {
    case xyPlane
    case xzPlane
    case yzPlane
    case orthoAngle
    case volume
    //    case Sector
}

extension URL {
    public func fileExists() -> Bool {
        return true
    }
}

///DiskOutputTree handles all the naming of files and directories for input and output.  It is also responsible
///for querying the directory tree.  All the files are held in a root directory and the directories under that contain
///information (step, type) from iterative output.  The files within that directory are created from multiple nodes
///and contain identifying information in a corresponding json file.
///
///```
///SmallSampleData
///├── plot.volume.V5.step_00000050
///│   ├── Qvec.F3.node.0.0.0.V5.bin
///│   ├── Qvec.F3.node.0.0.0.V5.bin.json
///│   ├── ...
///│   ├── Qvec.node.1.1.1.V5.bin
///│   └── Qvec.node.1.1.1.V5.bin.json
///└── plot_slice.XZplane.V5.step_00000050.cut_28
///    ├── Qvec.node.0.1.0.V5.bin
///    ├── Qvec.node.0.1.0.V5.bin.json
///    ├── Qvec.F3.node.0.1.0.V5.bin
///    ├── Qvec.F3.node.0.1.0.V5.bin.json
///    ├── plot_slice.XZplane.V5.step_00000050.cut_28.rho.bin
///    ├── plot_slice.XZplane.V5.step_00000050.cut_28.ux.bin
///    ├── plot_slice.XZplane.V5.step_00000050.cut_28.uy.bin
///    └── plot_slice.XZplane.V5.step_00000050.cut_28.uz.bin
///```
public struct DiskOutputTree {

    //    public let fm = FileManager.default

    public var rootDir: URL

    let grid: Grid = Grid(x: 0, y: 0, z: 0, ngx: 0, ngy: 0, ngz: 0)
    //    let cuJson: ComputeUnitJson
    //    let flow: Flow<T>

    let PlotFilesVersion: Int = 5

    /// Initialize with disk string (shared storage) and root string.
    ///
    /// Throws an error if `URL` cannot be formed with the string or the directory cannot be created
    public init(rootDir: URL, createDir: Bool = false) throws {
        self.rootDir = rootDir

        if createDir {
            try createDirIfDoesntExist(self.rootDir)
            // TODO: Check can write directory below
        }
    }
    
    /// Initialize with string.
    ///
    /// Throws an error if `URL` cannot be formed with the string or the directory cannot be created
    public init(rootDir: String, createDir: Bool = false) throws {

        let rootDirURL = URL(fileURLWithPath: rootDir, isDirectory: true)
        try self.init(rootDir: rootDirURL, createDir: createDir)
    }
    
    
    public init(diskDir: String, rootDir: String, createDir: Bool = false) throws {

        var rootDirURL = URL(fileURLWithPath: diskDir, isDirectory: true)
        rootDirURL.appendPathComponent(rootDir)

        try self.init(rootDir: rootDirURL, createDir: createDir)
    }

    /// Figure out the root directory from an array of strings
    public init(dirs: [String]) throws {

        //TODO
        //find the root dir in /xx/xx/rootDir/.*types.step_0000000
        
        self.rootDir = URL(fileURLWithPath: "PossibleRootDir", isDirectory: true)
        
        guard self.dirExists(self.rootDir) else {
            fatalError("Cannot determine root Dir")
        }
    }
    




    public init() throws {
        let fm = FileManager.default
        let dir = fm.currentDirectoryPath
        try self.init(diskDir: dir, rootDir: "tdLBOutputTreeDefault")
    }

    #if os(macOS)
        public init(rootDirInHome: String, createDir: Bool = false) throws {
            let fm = FileManager.default
            let dir = fm.homeDirectoryForCurrentUser.appendingPathComponent(rootDirInHome)
            try self.init(rootDir: dir, createDir: createDir)
        }
    #endif

    private func createDirIfDoesntExist(_ dir: URL) throws {
        let fm = FileManager.default

        var isDirectory = ObjCBool(true)
        if !fm.fileExists(atPath: dir.path, isDirectory: &isDirectory) {

            try fm.createDirectory(atPath: dir.path, withIntermediateDirectories: false)
        }
    }

    public func dirExists(_ dir: URL) -> Bool {
        let fm = FileManager.default

        var isDirectory = ObjCBool(true)
        return fm.fileExists(atPath: dir.path, isDirectory: &isDirectory)
    }

    public func fileExists(_ fullPath: URL) -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: fullPath.path)
    }

    // MARK: Format dirs

    private func formatVersion(_ version: Int) -> String {
        return "V\(version)"
    }

    private func formatStep(_ step: tStep) -> String {
        return String(format: "step_%08d", step)
    }

    private func formatDir(prefix: String, plotType: String, step: tStep) -> String {
        return "\(prefix).\(plotType).V5.step_\(formatStep(step))"
    }

    public func xyPlaneDir(step: tStep, atK: tNi, prefix: String = "plot") -> String {

        return formatDir(prefix: prefix, plotType: "XYplane", step: step) + ".cut_\(atK)"
    }

    //Formally Slice
    public func yzPlaneDir(step: tStep, atI: tNi, prefix: String = "plot") -> String {

        return formatDir(prefix: prefix, plotType: "YZplane", step: step) + ".cut_\(atI)"
    }

    //Formally Axis
    public func xzPlaneDir(step: tStep, atJ: tNi, prefix: String = "plot") -> String {

        return formatDir(prefix: prefix, plotType: "YZplane", step: step) + ".cut_\(atJ)"
    }

    public func volumeDir(step: tStep, prefix: String = "plot") -> String {
        return formatDir(prefix: prefix, plotType: "volume", step: step)
    }

    public func captureAtBladeAngleDir(step: tStep, angle: Int, bladeId: Int, prefix: String = "plot") -> String {

        return formatDir(prefix: prefix, plotType: "rotational_capture", step: step)
            + ".angle_\(angle).bladeId_\(bladeId)"
    }

    public func axisWhenBladeAngleDir(step: tStep, angle: Int, prefix: String = "plot") -> String {

        return formatDir(prefix: prefix, plotType: "YZplane", step: step) + ".angle_\(angle)"
    }

    public func rotatingSectorDir(step: tStep, angle: Int, prefix: String = "plot") -> String {

        return "Undefined_Sector"
    }

    private func formatCUid(idi: Int, idj: Int, idk: Int) -> String {
        return "CUid.\(idi).\(idj).\(idk).V5"
    }

    public func qVecBinFile(plotDir: URL, idi: Int, idj: Int, idk: Int) -> URL {
        return plotDir.appendingPathComponent(formatCUid(idi: idi, idj: idj, idk: idk) + ".QVec.bin")
    }

    public func forceBinFile(plotDir: URL, idi: Int, idj: Int, idk: Int) -> URL {
        return plotDir.appendingPathComponent(formatCUid(idi: idi, idj: idj, idk: idk) + ".Force.bin")
    }

    func qVecBinFileJSON(plotDir: URL, idi: Int, idj: Int, idk: Int) -> URL {

        return qVecBinFile(plotDir: plotDir, idi: idi, idj: idj, idk: idk).appendingPathExtension(".json")
    }

    func forceBinFileJSON(plotDir: URL, idi: Int, idj: Int, idk: Int) -> URL {

        return forceBinFile(plotDir: plotDir, idi: idi, idj: idj, idk: idk).appendingPathExtension(".json")
    }

    public func writeBinFileJson(to dir: URL) {
        //TODO Needs, grid, flow and cuJson initialised
        //Writes all the json files
    }

    public func confirmGridSizes(from files: [URL]) -> (Int, Int, Int) {
        //TODO cycle through all binfile jsons
        //Confirm all are equal
        //return the grid size

        return (44, 44, 44)
    }

    public func confirmHeigfhtWidthSizes(from files: [URL]) -> (Int, Int) {
        //TODO cycle through all binfile jsons
        //Confirm all height and width are the same
        //return the height and width

        return (44, 44)
    }

    public func loadBinFileJson(from file: URL) -> BinFileFormat? {
        do {
            return try BinFileFormat(file)
        }
        catch {
            print("Cannot load json at \(file.path)")
            return nil
        }
    }

    private func formatOutputURL(to writeDir: URL, ext: String) -> URL {

        let fileName = "\(writeDir.lastPathComponent).\(ext)"

        return self.rootDir.appendingPathComponent(fileName)
    }

    public func rho(for writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "rho.bin")
    }
    public func ux(for writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "ux.bin")
    }
    public func uy(for writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "uy.bin")
    }
    public func uz(for writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "uz.bin")
    }
    public func vorticity(for writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "vorticity.bin")
    }
    
    public func velocitiesExist(in dir: URL) -> Bool {
        
        return (
            self.fileExists(self.rho(for: dir)) &&
            self.fileExists(self.ux(for: dir)) &&
            self.fileExists(self.uy(for: dir)) &&
            self.fileExists(self.uz(for: dir))
        )
    }
    
    public func vorticityExist(in dir: URL) -> Bool {
        
        return self.fileExists(self.vorticity(for: dir))
    }

    

    // MARK: Finding Plot Dirs

    public func findAllDirs(withRegex regex: String = ".*V5\\.step.*") -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
        let fm = FileManager.default

        var directoryContents: [URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: self.rootDir, includingPropertiesForKeys: nil)
        }
        catch {
            return [URL]()
        }

        let filteredDirNames = directoryContents.filter {
            $0.hasDirectoryPath && $0.lastPathComponent.range(of: regex, options: .regularExpression) != nil
        }

        return filteredDirNames

    }

    func findOrthoPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int? = nil, step: tStep? = nil) -> [URL] {

        //plot.XYplane.V5.step_00000010.cut_14

        var regex: String = ".*\(orientation.self).*"
        if let hasStep = step {
            regex += "step_\(formatStep(hasStep))"
        }
        if let hasCutAt = cutAt {
            regex += "cut_\(hasCutAt)"
        }
        return findAllDirs(withRegex: regex)
    }

    public func findXYPlaneDirs(cutAt: Int? = nil, step: tStep? = nil) -> [URL] {
        findOrthoPlaneDirs(orientation: .xyPlane, cutAt: cutAt, step: step)
    }

    public func findXZPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int? = nil, step: tStep? = nil) -> [URL] {
        findOrthoPlaneDirs(orientation: .xzPlane, cutAt: cutAt, step: step)
    }

    public func findYZPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int? = nil, step: tStep? = nil) -> [URL] {
        findOrthoPlaneDirs(orientation: .yzPlane, cutAt: cutAt, step: step)
    }
    
    public func findVolumeDirs(withStep step: tStep? = nil) -> [URL] {
        if let hasStep = step {
            return findAllDirs(withRegex: ".*volume\\.V5\\.step_\(formatStep(hasStep))")
        }
        return findAllDirs(withRegex: ".*volume.*")
    }

    public func formatCaptureAtBladeAngleDir(tStep step: tStep, angle: Int, blade_id: Int, prefix: String = "plot") {
        //TODO

    }
    public func formatAxisWhenBladeAngleDir(step: tStep, angle: Int, prefix: String = "plot") {
        //TODO

    }

    public func findRotatingSectorDir() {
        //TODO

    }

    // MARK: find files from a plot Directory

    private func findFiles(at dir: URL, withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
        let fm = FileManager.default

        var directoryContents: [URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        }
        catch {
            return [URL]()
        }

        return directoryContents.filter { $0.lastPathComponent.range(of: regex, options: .regularExpression) != nil }
    }

    public func findQVecBin(at dir: URL) -> [URL] {
        return findFiles(at: dir, withRegex: "^CUid.*\\.Qvec\\.bin$")
    }

    public func findQVecBinJson(at dir: URL) -> [URL] {
        return findFiles(at: dir, withRegex: "^CUid.*\\.Qvec\\.bin\\.json$")
    }

    public func findForceBin(at dir: URL) -> [URL] {
        return findFiles(at: dir, withRegex: "^CUid.*\\.Force\\.bin$")
    }

    public func findForceBinJson(at dir: URL) -> [URL] {
        return findFiles(at: dir, withRegex: "^CUid.*\\.Force\\.bin\\.json$")
    }

    // MARK: Query Dirs

    public func step(dir: URL) -> tStep? {
        let plotStr = dir.lastPathComponent
        if let result = plotStr.range(of: #"step_([0-9]*)"#, options: .regularExpression) {
            let i = plotStr[result].index(plotStr[result].startIndex, offsetBy: 5)
            return tStep(plotStr[result][i...])
        }
        else {
            return nil
        }
    }

    public func cutAt(dir: URL) -> Int? {
        let plotStr = dir.lastPathComponent
        if let result = plotStr.range(of: #"cut_([0-9]*)"#, options: .regularExpression) {
            let i = plotStr[result].index(plotStr[result].startIndex, offsetBy: 4)
            return Int(plotStr[result][i...])
        }
        else {
            return nil
        }
    }

    public func dirKind(dir: URL) -> PlotDirKind? {
        let plotStr = dir.lastPathComponent

        if plotStr.contains("XYPlane") {
            return .xyPlane
        }
        else if plotStr.contains("XZPlane") {
            return .xzPlane
        }
        else if plotStr.contains("YZPlane") {
            return .xzPlane
        }
        else if plotStr.contains("OrthoAngle") {
            return .orthoAngle
        }
        else if plotStr.contains("Volume") {
            return .volume
        }
        //        if plotStr.contains("Sector") {return .Sector}
        return nil
    }

    public func replaceLastPathComponent(dir: URL, with path: String) -> URL {

        let tmp = dir.deletingLastPathComponent()
        let url = tmp.appendingPathComponent(path)
        return url
    }

    public func lastTwoPathComponents(dir: URL) -> String {

        let u = dir.lastPathComponent
        let v = dir.deletingLastPathComponent()
        return v.lastPathComponent + "/" + u
    }

    public func formatCutDelta(dir: URL, withDelta: Int) -> URL? {

        guard let hasCut: Int = self.cutAt(dir: dir) else {
            return nil
        }

        let replace: String = "cut_\(hasCut + withDelta)"

        let newDir = dir.lastPathComponent.replacingOccurrences(
            of: #"cut_[0-9]*"#,
            with: replace,
            options: .regularExpression
        )

        return replaceLastPathComponent(dir: dir, with: newDir)
    }

    public func formatCutDelta(dir: URL, with replaceCut: Int) -> URL? {

        guard self.cutAt(dir: dir) != nil else {
            return nil
        }

        let replace: String = "cut_\(replaceCut)"

        let newDir = dir.lastPathComponent.replacingOccurrences(
            of: #"cut_[0-9]*"#,
            with: replace,
            options: .regularExpression
        )

        return replaceLastPathComponent(dir: dir, with: newDir)

    }

}
