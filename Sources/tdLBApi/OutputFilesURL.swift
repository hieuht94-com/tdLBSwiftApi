//
//  InputFilesV4URL.swift
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
    case OtherDiskError
}

public enum DirType {
    case XYplane
    case XZplane
    case YZplane
    case rotational
    case volume
    //    case sector
    case None
}



public func formatStep(_ step: Int) -> String {
    return String(format: "%08d", step)
}


/**
 An OutputDir is a the path of a local file on disk that exists and is writable or is created.
 */
public struct OutputDir {

    let OutputFilesURLVersion:Int = 4

    let root:URL

    var plotDir: String = ""



    /// Initialize with string.
    ///
    /// Throws an error is `URL` cannot be formed with the string or the directory cannot be created
    public init(_ rootDir:String) throws {

        self.root = URL(fileURLWithPath: rootDir, isDirectory: true)

        try createDirIfDoesntExist(rootDir)
        //Check can write directory below

    }

    public init() throws {
        let fm = FileManager.default
        let dir = fm.currentDirectoryPath
        try self.init(dir)
    }

    public init(rootDirInHome:String) throws {
        let fm = FileManager.default
        let dir = fm.homeDirectoryForCurrentUser.path + rootDirInHome

        try self.init(dir)
    }

    public init(_ rootDir:URL) throws {
        try self.init(rootDir.absoluteString)
    }



    private func createDirIfDoesntExist(_ dir:String) throws {
        let fm = FileManager.default

        var isDirectory = ObjCBool(true)
        if !fm.fileExists(atPath: dir, isDirectory: &isDirectory){

            try fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
        }
    }


    func createPlotDir(_ plotDir: String) -> URL {

        let newPlotDir:String = self.root.appendingPathComponent(plotDir).path

        do {
            try createDirIfDoesntExist(newPlotDir)
        } catch {
            //TODO Test if drive full, otherwise should not happen
            //if Drive full then balk
            print(error.localizedDescription)
        }

        return URL(fileURLWithPath: newPlotDir, isDirectory: true)
    }




    // MARK: Working with root dir

    private func getDirs(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        var directoryContents: [URL]
        do {
            directoryContents = try fm.contentsOfDirectory(at: self.root, includingPropertiesForKeys: nil)
        } catch {
            return [URL]()
        }


        let dirNames = directoryContents.map{ $0.lastPathComponent }

        let filteredDirNames = dirNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredDirsURLs = filteredDirNames.map{self.root.appendingPathComponent($0)}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return filteredDirsURLs

    }



    func subDirsStep(at: Int) -> [URL] {
        return getDirs(withRegex: ".*step_\(formatStep(at)).*")
    }
    func subDirsAllXYPlanes() -> [URL]  {
        return getDirs(withRegex: ".*XYplane.*")
    }
    func subDirsAllXZPlanes() -> [URL]  {
        return getDirs(withRegex: ".*XZplane.*")
    }
    func subDirsAllYZPlanes() -> [URL]  {
        return getDirs(withRegex: ".*YZplane.*")
    }
    func subDirsAllVolume() -> [URL]  {
        return getDirs(withRegex: ".*volume.*")
    }
    func subDirsAllRotational() -> [URL]  {
        return getDirs(withRegex: ".*rotational_capture.*")
    }
    func subDirsAll()  -> [URL] {
        return getDirs(withRegex: ".*")
    }







    func getPlotDir(_ plotDir:String) -> URL {
        return createPlotDir(plotDir)
    }



    private func getFiles(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        var directoryContents:[URL]

        do {
        directoryContents = try fm.contentsOfDirectory(at: self.root, includingPropertiesForKeys: nil)

        } catch {
            print(error)
            return [URL]()
        }

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredBinFileURLs = filteredBinFileNames.map{self.root.appendingPathComponent($0)}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return filteredBinFileURLs

    }


    private func qVecBinRegex() -> String {
        return "^Qvec\\.node\\..*\\.bin$"
    }

    private func F3BinRegex() -> String {
        return "^Qvec\\.F3\\.node\\..*\\.bin$"
    }

    //    private func faceDeltas() -> [facesIJK] {
    //        return facesIJK.allCases
    //    }
    //
    //    private func qVecRotationBinRegex(delta: facesIJK) -> String {
    //        return "^Qvec\\.\(delta)\\.node\\..*\\.bin$"
    //    }
    //
    //    private func F3RotationBinRegex(delta: facesIJK) -> String {
    //        return "^Qvec\\.F3\\.\(delta)\\.node\\..*\\.bin$"
    //    }



    func getQvecFiles() -> [URL] {
        return getFiles(withRegex: self.qVecBinRegex())
    }

    func getF3Files() -> [URL] {
        return getFiles(withRegex: self.F3BinRegex())
    }




    //    func getQvecRotationFiles(faceDelta: facesIJK) throws -> [URL] {
    //        return try getFiles(withRegex: qVecRotationBinRegex(delta: faceDelta))
    //    }
    //
    //    func getF3RotationFiles(faceDelta: facesIJK) throws -> [URL] {
    //        return try getFiles(withRegex: F3RotationBinRegex(delta: faceDelta))
    //    }



    // MARK: Loading Files

    func getPPDim(plotDir: String) -> ppDim? {
        do {
            let plot:URL = getPlotDir(plotDir)
            return try ppDim(dir: plot)
        } catch {
            return nil
        }
    }


    private func formatDirRoot(name: String = "plot", type: DirType, QLength: Int, step: Int) -> String {
        return "\(name).\(type).V_\(self.OutputFilesURLVersion).Q_\(QLength).step_\(formatStep(step))"
    }


    // MARK: Query plotDirs


    func name(plotDir: String) -> String? {
        //        return self.dir.lastPathComponent.components(separatedBy: ".")[0]
        return plotDir.components(separatedBy: ".")[0]
    }

    func dirType(plotDir: String) -> DirType {

        if plotDir.contains(".XYplane.") {return .XYplane}
        else if plotDir.contains(".XZplane.") {return .XZplane}
        else if plotDir.contains(".YZplane.") {return .YZplane}
        else if plotDir.contains(".volume.") {return .volume}
        else if plotDir.contains(".rotational_capture.") {return .rotational}
            //        else if dir.contains(".sector.") {return .sector}
        else {
            return .None
        }
    }

    func isPlotDir(plotDir:String, thisType: DirType) -> Bool {
        return thisType == dirType(plotDir:plotDir)
    }


    func version(plotDir: String) -> Int? {
        if let result = plotDir.range(of: #"V_([0-9]*)"#, options: .regularExpression){
            let i = plotDir[result].index(plotDir[result].startIndex, offsetBy: 2)
            return Int(plotDir[result][i...])
        } else {
            return nil
        }
    }

    func qLength(plotDir: String) -> Int? {
        if let result = plotDir.range(of: #"Q_([0-9]*)"#, options: .regularExpression){
            let i = plotDir[result].index(plotDir[result].startIndex, offsetBy: 2)
            return Int(plotDir[result][i...])
        } else {
            return nil
        }
    }

    func step(plotDir: String) -> Int? {
        if let result = plotDir.range(of: #"step_([0-9]*)"#, options: .regularExpression){
            let i = plotDir[result].index(plotDir[result].startIndex, offsetBy: 5)
            return Int(plotDir[result][i...])
        } else {
            return nil
        }
    }


    func cut(plotDir: String) -> Int? {
        if let result = plotDir.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = plotDir[result].index(plotDir[result].startIndex, offsetBy: 4)
            return Int(plotDir[result][i...])
        } else {
            return nil
        }
    }




    // MARK: Make new directories

    public func getXYPlane(atK: Int, step:Int) -> URL {


        let dir = formatXYPlane(QLength: 4, step: step, atK: atK)

        return createPlotDir(dir)
    }




    func formatXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"

        //        FileManager.createDirectory(dir)
    }
    //    func getXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> URL {
    //
    //        let str = formatXYPlane(name:"plot_vertical_axis", QLength:QLength, step: step, atK: atK)
    //
    //        let dir = outputDir.url.appendingPathComponent(str, isDirectory: true)
    //
    //
    //        //TODO create dir
    //
    //
    //
    //        return dir
    //    }

    func formatXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> String{

        let root = formatDirRoot(name: name, type: DirType.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    func formatYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }


    func formatVolume(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatDirRoot(name: name, type: DirType.volume, QLength: QLength, step: step)
    }



    func formatCaptureAtBladeAngle(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    func formatAxisWhenBladeAngle(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatDirRoot(name: name, type: DirType.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }

    func formatRotatingSector(name: String="plot", step: Int, angle: Int, QLength: Int) {
    }


    func formatCutDelta(plotDir:String, delta: Int) throws -> String {
        if let cut = self.cut(plotDir: plotDir) {

            let replace: String = "cut_\(cut + delta)"

            //            let newDir = self.dir.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            let newDir = plotDir.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }



    func formatCutDelta(plotDir:String, replaceCut: Int) throws -> String {
        if let _ = self.cut(plotDir: plotDir) {

            let replace: String = "cut_\(replaceCut)"

            //            let newDir = self.dir.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)
            let newDir = plotDir.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            //            print(fromDir, replace, newDir)
            return newDir
        } else {
            throw diskErrors.OtherDiskError
        }
    }







    // MARK: Working with bin and bin.json files



    private func formatQVecFileRoot(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(self.OutputFilesURLVersion)"
    }

    func formatQVecBin(name: String, idi: Int, idj: Int, idk: Int) -> String {
        return "\(formatQVecFileRoot(name, idi, idj, idk)).bin"
    }

    func formatNode000QVecBin(name: String) -> String {
        return formatQVecBin(name: name, idi: 0, idj: 0, idk: 0)
    }


    func getNode000QVecBinFile(name: String) -> URL {
        return URL(fileURLWithPath: formatQVecBin(name: name, idi: 0, idj: 0, idk: 0))
    }



}










