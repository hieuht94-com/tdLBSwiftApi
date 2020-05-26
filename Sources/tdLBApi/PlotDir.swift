//
//  InputFilesV4URL.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 24/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//

import Foundation




public enum PlotDirKind: String {
    case XYplane = "XYplane"
    case XZplane = "XZplane"
    case YZplane = "YZplane"
    case rotational = "rotational_capture"
    case volume = "volume"
    //    case sector = "sector"
}





//TODO Better way to do this?

public typealias PlotDir = URL

public extension URL {


    var OutputFilesURLVersion: Int {
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




    func getPPDim() -> ppDim? {
        do {
            return try ppDim(dir: self)
        } catch {
            return nil
        }
    }

    

    func ppDimURL() -> URL {
        //TODO V4??
        return self.appendingPathComponent("Post_Processing_Dims_dims.0.0.0.V4.json")
    }






    // MARK: Getting bin and bin.json files


    func getQvecFiles() -> [URL] {
        return getFiles(withRegex: qVecBinRegex())
    }

    func getF3Files() -> [URL] {
        return getFiles(withRegex: F3BinRegex())
    }




    // MARK: Formatting names of bin and bin.json files

    enum ext: String {
        case bin = "bin"
        case json = "json"
    }

    enum PlotDirKind: String {
        case XYplane = "XYplane"
        case XZplane = "XZplane"
        case YZplane = "YZplane"
        case rotational = "rotational_capture"
        case volume = "volume"
        //    case sector = "sector"
    }





    private func formatQVecFile(_ name: String, _ idi: Int, _ idj: Int, _ idk: Int, _ ext: ext) -> String {
        return "\(name).node.\(idi).\(idj).\(idk).V\(self.OutputFilesURLVersion).\(ext)"
    }




    func QVecBinFileURL(name: String, idi: Int, idj: Int, idk: Int) -> URL {

        return URL(fileURLWithPath: formatQVecFile(name, idi, idj, idk, .bin))


    }

    func QVecBinFileJSON(name: String, idi: Int, idj: Int, idk: Int) -> URL {

        return URL(fileURLWithPath: formatQVecFile(name, idi, idj, idk, .json))
    }




    func Node000QVecBinFileURL(name: String) -> URL {

        return QVecBinFileURL(name: name, idi: 0, idj: 0, idk: 0)
    }

    func Node000QVecBinFileJSON(name: String) -> URL {

        return QVecBinFileJSON(name: name, idi: 0, idj: 0, idk: 0)
    }




}










