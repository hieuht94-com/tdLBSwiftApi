//
//  DiskOutputTree.swift
//  tdQVecTool
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
    case OtherDiskError
}


public enum OrthoPlaneOrientation {
    case XYPlane
    case XZPlane
    case YZPlane
}


///An OutputDir is a the path of a local file on disk that exists and is writable or is created and writable
public struct DiskOutputTree {
    
    //    public let fm = FileManager.default
    
    public var rootDir: URL
    
    let grid: Grid = Grid(x:0, y:0, z:0, ngx:0, ngy:0, ngz:0)
    //    let cuJson: ComputeUnitJson
    //    let flow: Flow<T>
    
    let PlotFilesVersion:Int = 5
    
    /// Initialize with string.
    ///
    /// Throws an error if `URL` cannot be formed with the string or the directory cannot be created
    public init(diskDir: String, rootDir: String, createDir: Bool = false) throws {
        
        
        self.rootDir = URL(fileURLWithPath: diskDir, isDirectory: true)
        self.rootDir.appendPathComponent(rootDir)
        
        if createDir {
            try createDirIfDoesntExist(self.rootDir)
            // TODO: Check can write directory below
        }
        
    }
    
    public init(rootDir: URL, createDir: Bool = false) throws {
        self.rootDir = rootDir
        
        if createDir {
            try createDirIfDoesntExist(self.rootDir)
            // TODO: Check can write directory below
        }
    }
    
    public init() throws {
        let fm = FileManager.default
        let dir = fm.currentDirectoryPath
        try self.init(diskDir: dir, rootDir: "tdLBOutputDefaultDir")
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
        if !fm.fileExists(atPath: dir.path, isDirectory: &isDirectory){
            
            try fm.createDirectory(atPath: dir.path, withIntermediateDirectories: false)
        }
    }
    
    public func dirExists(_ dir: URL){
        let fm = FileManager.default
        
        var isDirectory = ObjCBool(true)
        fm.fileExists(atPath: dir.path, isDirectory: &isDirectory)
    }
    
    public func fileExists(_ fullPath: URL){
        let fm = FileManager.default
        fm.fileExists(atPath: fullPath.path)
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
        
        return formatDir(prefix: prefix, plotType: "XYplane", step:step) + ".cut_\(atK)"
    }
    
    //Formally Slice
    public func yzPlaneDir(step: tStep, atI: tNi, prefix: String = "plot") -> String {
        
        return formatDir(prefix: prefix, plotType: "YZplane", step:step) + ".cut_\(atI)"
    }
    
    //Formally Axis
    public func xzPlaneDir(step: tStep, atJ: tNi, prefix: String = "plot") -> String {
        
        return formatDir(prefix: prefix, plotType: "YZplane", step:step)  + ".cut_\(atJ)"
    }
    
    public func volumeDir(step: tStep, prefix: String = "plot") -> String {
        return formatDir(prefix: prefix, plotType: "volume", step:step)
    }
    
    
    public func captureAtBladeAngleDir(step: tStep, angle: Int, bladeId: Int, prefix: String = "plot") -> String {
        
        return formatDir(prefix:prefix, plotType: "rotational_capture", step:step) + ".angle_\(angle).bladeId_\(bladeId)"
    }
    
    public func axisWhenBladeAngleDir(step: tStep, angle: Int, prefix: String = "plot") -> String {
        
        return formatDir(prefix:prefix, plotType: "YZplane", step: step) + ".angle_\(angle)"
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
    
    
    public func writeBinFileJson(to dir: URL){
        //TODO Needs, grid, flow and cuJson initialised
        //Writes all the json files
    }
    
    
    
    
    
    
    private func formatOutputURL(to writeDir: URL, ext: String) -> URL {
        
        
        let fileName = "\(writeDir.lastPathComponent).\(ext)"
        
        return self.rootDir.appendingPathComponent(fileName)
    }
    
    
    func rho(to writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "rho.bin")
    }
    func ux(to writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "ux.bin")
    }
    func uy(to writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "uy.bin")
    }
    func uz(to writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "uz.bin")
    }
    func vorticity(to writeDir: URL) -> URL {
        return formatOutputURL(to: writeDir, ext: "vorticity.bin")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: Getting Plot Dirs
    
    
    
    private func getDirs(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
        let fm = FileManager.default
        
        var directoryContents: [URL]
        
        do {
            directoryContents = try fm.contentsOfDirectory(at: self.rootDir, includingPropertiesForKeys: nil)
        } catch {
            return [URL]()
        }
        
        let filteredDirNames = directoryContents.filter{$0.hasDirectoryPath && $0.lastPathComponent.range(of: regex, options:.regularExpression) != nil}
        
        return filteredDirNames
        
    }
    
    
    public func getAllDirs() -> [URL] {
        return getDirs(withRegex: ".*")
    }
    
    
    //    public func getDirs(withSteps step: [Int]) -> [URL] {
    //        //TODO
    //        return getDirs(withRegex: ".*\(formatStep(step)).*")
    //    }
    
    
    func orthoPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int?=nil, step:tStep?=nil) -> [URL] {
        
        //plot.XYplane.V5.step_00000010.cut_14
        
        var regex: String = ".*\(orientation.self).*"
        if let hasStep = step {
            regex += "step_\(formatStep(hasStep))"
        }
        if let hasCutAt = cutAt {
            regex += "cut_\(hasCutAt)"
        }
        return getDirs(withRegex: regex)
    }
    
    public func getXYPlaneDirs(cutAt: Int? = nil, step:tStep? = nil) -> [URL] {
        orthoPlaneDirs(orientation: .XYPlane, cutAt: cutAt, step: step)
    }
    
    public func getXZPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int?=nil, step:tStep?=nil) -> [URL] {
        orthoPlaneDirs(orientation: .XZPlane, cutAt: cutAt, step: step)
    }
    
    public func getYZPlaneDirs(orientation: OrthoPlaneOrientation, cutAt: Int?=nil, step:tStep?=nil) -> [URL] {
        orthoPlaneDirs(orientation: .YZPlane, cutAt: cutAt, step: step)
    }
    
    
    public func getVolumeDirs(withStep step: tStep? = nil) -> [URL] {
        if let hasStep = step {
            return getDirs(withRegex: ".*volume\\.V5\\.step_\(formatStep(hasStep))")
        }
        return getDirs(withRegex: ".*volume.*")
    }
    
    public func formatCaptureAtBladeAngleDir(tStep step: tStep, angle: Int, blade_id: Int, prefix: String = "plot"){
        //TODO
        
    }
    public func formatAxisWhenBladeAngleDir(step: tStep, angle: Int, prefix:String = "plot"){
        //TODO
        
    }
    
    
    public func getRotatingSectorDir(){
        //TODO
        
    }
    
    
    // MARK: Get files from a plot Directory
    
    private func getFiles(at dir: String, withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526
        let fm = FileManager.default
        
        var directoryContents: [URL]
        
        do {
            let url = self.rootDir.appendingPathComponent(dir)
            directoryContents = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
        } catch {
            return [URL]()
        }
        
        return directoryContents.filter{$0.lastPathComponent.range(of: regex, options:.regularExpression) != nil}
    }
    
    
    
    public func getQVecBin(at dir: String) -> [URL] {
        return getFiles(at:dir, withRegex: "^CUid.*\\.Qvec\\.bin$")
    }
    
    public func getQVecBinJson(at dir: String) -> [URL] {
        return getFiles(at:dir, withRegex: "^CUid.*\\.Qvec\\.bin\\.json$")
    }
    
    public func getForceBin(at dir: String) -> [URL] {
        return getFiles(at:dir, withRegex: "^CUid.*\\.Force\\.bin$")
    }
    
    public func getForceBinJson(at dir: String) -> [URL] {
        return getFiles(at: dir, withRegex: "^CUid.*\\.Force\\.bin\\.json$")
    }
    
    
    
    // MARK: Query Dirs
    
    func step(dir: URL) -> Int? {
        let plotStr = dir.lastPathComponent
        if let result = plotStr.range(of: #"step_([0-9]*)"#, options: .regularExpression){
            let i = plotStr[result].index(plotStr[result].startIndex, offsetBy: 5)
            return Int(plotStr[result][i...])
        } else {
            return nil
        }
    }
    
    
    func cut(dir: URL) -> Int? {
        let plotStr = dir.lastPathComponent
        if let result = plotStr.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = plotStr[result].index(plotStr[result].startIndex, offsetBy: 4)
            return Int(plotStr[result][i...])
        } else {
            return nil
        }
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
        
        guard let hasCut: Int = self.cut(dir: dir) else {
            return nil
        }
        
        let replace: String = "cut_\(hasCut + withDelta)"
        
        let newDir = dir.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)
        
        return replaceLastPathComponent(dir: dir, with: newDir)
    }
    
    
    public func formatCutDelta(dir: URL, with replaceCut: Int) -> URL? {
        
        guard self.cut(dir: dir) != nil else {
            return nil
        }
        
        
        let replace: String = "cut_\(replaceCut)"
        
        let newDir = dir.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)
        
        return replaceLastPathComponent(dir: dir, with: newDir)
        
    }
    
    
    
}

