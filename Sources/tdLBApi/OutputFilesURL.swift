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
    case PlotDir
    case NotPlotDir
    case OtherDiskError
}

public enum PlotDirKind: String {
    case XYplane = "XYplane"
    case XZplane = "XZplane"
    case YZplane = "YZplane"
    case rotational = "rotational_capture"
    case volume = "volume"
    //    case sector = "sector"
}





/**
 An OutputDir is a the path of a local file on disk that exists and is writable or is created and writable
 */
public struct OutputDir {

    public let root:URL


    let PlotFilesVersion:Int = 4
    var formatVersion: String {
        return formatVersion(PlotFilesVersion)
    }



    /// Initialize with string.
    ///
    /// Throws an error if `URL` cannot be formed with the string or the directory cannot be created
    public init(_ rootDir:String, createDir: Bool = false) throws {

        //TODO use formatVersion(PlotFilesVersion)
        if rootDir.contains("V_4") {
            throw diskErrors.PlotDir
        }


        self.root = URL(fileURLWithPath: rootDir, isDirectory: true)

        if createDir {
            try createDirIfDoesntExist(rootDir)
            //Check can write directory below
        }

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







    // MARK: Getting Plot Dirs

    private func getPlotDirs(withRegex regex: String) -> [PlotDir] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        var directoryContents: [URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: self.root, includingPropertiesForKeys: nil)
        } catch {
            return [PlotDir]()
        }

        //TODO Find only Directories


        let dirNames = directoryContents.map{ $0.lastPathComponent }

        let filteredDirNames = dirNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredDirsURLs = filteredDirNames.map{self.root.appendingPathComponent($0)}

        return filteredDirsURLs

    }


    private func formatVersion(_ version: Int) -> String {
        return "V_\(version)"
    }

    private func formatQLength(_ QLength: Int) -> String {
        return "Q_\(QLength)"
    }

    private func formatStep(_ step: Int) -> String {
        return String(format: "step_%08d", step)
    }



    //TODO
//    func formatRotatingSector(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {
//        return "TODO"
//    }



    func plotDirs() -> [PlotDir] {
        return getPlotDirs(withRegex: ".*")
    }


    func plotDirs(withKind kind: PlotDirKind) -> [PlotDir] {
        switch kind {
            case .XYplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.XYplane.self).*")
            case .XZplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.XZplane.self).*")
            case .YZplane:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.YZplane.self).*")
            case .volume:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.volume.self).*")
            case .rotational:
                return getPlotDirs(withRegex: ".*\(PlotDirKind.rotational.self).*")
        }
    }


    func plotDirs(withVersion version: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatVersion(version)).*")
    }

    func plotDirs(withQLength QLength: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatQLength(QLength)).*")
    }

    func plotDirs(withStep step: Int) -> [PlotDir] {
        return getPlotDirs(withRegex: ".*\(formatStep(step)).*")
    }




    // MARK: Creating Plot Dirs



    private func createPlotDir(_ plotDir: String) -> PlotDir {

        let newPlotDir:String = self.root.appendingPathComponent(plotDir).path

        do {
            try createDirIfDoesntExist(newPlotDir)
        } catch {
            //TODO Test if drive full, otherwise should not happen
            //if Drive full then balk
            print(error.localizedDescription)
        }

        return PlotDir(fileURLWithPath: newPlotDir, isDirectory: true)
    }



    private func formatPlotDirRoot(name: String, kind: PlotDirKind, QLength: Int, step: Int) -> String {
        return "\(name).\(kind.rawValue).\(formatVersion).\(formatQLength(QLength)).\(formatStep(step))"
    }



    func formatXYPlane(name: String = "plot_vertical_axis", QLength: Int, step: Int, atK: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.XYplane, QLength: QLength, step: step)
        return "\(root).cut_\(atK)"
    }

    //TODO FIX this
    func createXYPlane(QLength: Int, step: Int, atK: Int) -> PlotDir {

        return createPlotDir(formatXYPlane(QLength: QLength, step: step, atK: atK))
    }





    func formatXZPlane(name: String = "plot_slice", QLength: Int, step: Int, atJ: Int) -> String{

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.XZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atJ)"
    }

    func formatYZPlane(name: String = "plot_axis", QLength: Int, step: Int, atI: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.YZplane, QLength: QLength, step: step)
        return "\(root).cut_\(atI)"
    }


    func formatVolume(name: String = "volume", QLength: Int, step: Int) -> String {

        return formatPlotDirRoot(name: name, kind: PlotDirKind.volume, QLength: QLength, step: step)
    }



    func formatCaptureAtBladeAngle(name: String="plot", step: Int, angle: Int, bladeId: Int, QLength: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.rotational, QLength: QLength, step: step)
        return "\(root).angle_\(angle).blade_id_\(bladeId)"
    }

    func formatAxisWhenBladeAngle(name: String="plot", step: Int, angle: Int, QLength: Int) -> String {

        let root = formatPlotDirRoot(name: name, kind: PlotDirKind.YZplane, QLength: QLength, step: step)
        return "\(root).angle_\(angle)"
    }







    // MARK: Working with bin and bin.json files



    private func formatQVecFileRoot(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(self.PlotFilesVersion)"
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



//TODO Better way to do this?

public typealias PlotDir = URL

public extension URL {



    func OutputFilesURLVersion() -> Int {
        return 4
    }


    func validate() -> Bool {
        return self.lastPathComponent.contains(".V_4.")
    }






    // MARK: Query plotDirs


    func name() -> String? {
        return self.lastPathComponent.components(separatedBy: ".")[0]
    }

    func dirType() -> PlotDirKind? {

        if self.lastPathComponent.contains(".\(PlotDirKind.XYplane.rawValue).") {return .XYplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.XZplane.rawValue).") {return .XZplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.YZplane.rawValue).") {return .YZplane}
        else if self.lastPathComponent.contains(".\(PlotDirKind.volume.rawValue).") {return .volume}
        else if self.lastPathComponent.contains(".\(PlotDirKind.rotational.rawValue).") {return .rotational}
            //        else if self.lastPathComponent.contains(".sector.") {return .sector}
        else {
            return nil
        }
    }



    func version() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"V_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 2)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }

    func qLength() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"Q_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 2)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }

    func step() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"step_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 5)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }


    func cut() -> Int? {
        let plotdir = self.lastPathComponent
        if let result = plotdir.range(of: #"cut_([0-9]*)"#, options: .regularExpression){
            let i = plotdir[result].index(plotdir[result].startIndex, offsetBy: 4)
            return Int(plotdir[result][i...])
        } else {
            return nil
        }
    }




    func formatCutDelta(delta: Int) throws -> PlotDir {
        if let cut = self.cut() {
            let replace: String = "cut_\(cut + delta)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            return PlotDir(fileURLWithPath: newDir)
        }else {
            throw diskErrors.OtherDiskError
        }
    }


    func formatCutDelta(replaceCut: Int) throws -> PlotDir {
        if let _ = self.cut() {

            let replace: String = "cut_\(replaceCut)"

            let newDir = self.lastPathComponent.replacingOccurrences(of: #"cut_[0-9]*"#, with: replace, options: .regularExpression)

            return PlotDir(fileURLWithPath: newDir)
        } else {
            throw diskErrors.OtherDiskError
        }
    }







    // MARK: Working with Files within a PlotDir


    func getPPDim(plotDir: String) -> ppDim? {
        do {
            return try ppDim(dir: self)
        } catch {
            return nil
        }
    }



    func getFiles(withRegex regex: String) -> [URL] {
        //https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder/27722526

        let fm = FileManager.default
        var directoryContents:[URL]

        do {
            directoryContents = try fm.contentsOfDirectory(at: self, includingPropertiesForKeys: nil)

        } catch {
            print(error)
            return [URL]()
        }

        let fileNames = directoryContents.map{ $0.lastPathComponent }

        let filteredBinFileNames = fileNames.filter{ $0.range(of: regex, options:.regularExpression) != nil}

        let filteredBinFileURLs = filteredBinFileNames.map{self.appendingPathComponent($0)}

        //        print(dirURL, directoryContents, fileNames, regex, filteredBinFileNames)

        return filteredBinFileURLs

    }


    func qVecBinRegex() -> String {
        return "^Qvec\\.node\\..*\\.bin$"
    }

    func F3BinRegex() -> String {
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


    //    func getQvecRotationFiles(faceDelta: facesIJK) throws -> [URL] {
    //        return try getFiles(withRegex: qVecRotationBinRegex(delta: faceDelta))
    //    }
    //
    //    func getF3RotationFiles(faceDelta: facesIJK) throws -> [URL] {
    //        return try getFiles(withRegex: F3RotationBinRegex(delta: faceDelta))
    //    }








    func getQvecFiles() -> [URL] {
        return getFiles(withRegex: qVecBinRegex())
    }

    func getF3Files() -> [URL] {
        return getFiles(withRegex: F3BinRegex())
    }




}










