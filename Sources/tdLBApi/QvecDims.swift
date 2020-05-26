//
//  QVecDims.swift
//  tdQVecTool
//
//  Created by Niall Ó Broin on 08/01/2019.
//  Copyright © 2019 Niall Ó Broin. All rights reserved.
//
import Foundation


public struct QVecDim: Codable {
    //https://app.quicktype.io#

    public let qDataType: String
    public let qOutputLength, binFileSizeInStructs: Int
    public let coordsType: String
    public let gridX, gridY, gridZ: Int
    public let hasColRowCoords, hasGridCoords: Bool
    public let idi, idj, idk: Int
    public let name: String
    public let ngx, ngy, ngz: Int
    public let structName: String

    enum CodingKeys: String, CodingKey {
        case qDataType = "Q_data_type"
        case qOutputLength = "Q_output_length"
        case binFileSizeInStructs = "bin_file_size_in_structs"
        case coordsType = "coords_type"
        case gridX = "grid_x"
        case gridY = "grid_y"
        case gridZ = "grid_z"
        case hasColRowCoords = "has_col_row_coords"
        case hasGridCoords = "has_grid_coords"
        case idi, idj, idk, name, ngx, ngy, ngz
        case structName = "struct_name"
    }

    public init(
        qDataType: String,
        qOutputLength:Int, binFileSizeInStructs: Int,
        coordsType: String,
        gridX:Int, gridY:Int, gridZ: Int,
        hasColRowCoords:Bool,
        hasGridCoords: Bool,
        idi: Int, idj: Int, idk: Int,
        name: String,
        ngx: Int,
        ngy: Int,
        ngz: Int,
        structName: String
    ){
        self.qDataType = qDataType
        self.qOutputLength = qOutputLength
        self.binFileSizeInStructs = binFileSizeInStructs
        self.coordsType = coordsType
        self.gridX = gridX
        self.gridY = gridY
        self.gridZ = gridZ
        self.hasColRowCoords = hasColRowCoords
        self.hasGridCoords = hasGridCoords
        self.idi = idi
        self.idj = idj
        self.idk = idk
        self.name = name
        self.ngx = ngx
        self.ngy = ngy
        self.ngz = ngz
        self.structName = structName

    }







}

extension QVecDim {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(QVecDim.self, from: data)
    }

    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(_ url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    //    public func with(
    //        qDataType: String? = nil,
    //        qOutputLength: Int? = nil,
    //        binFileSizeInStructs: Int? = nil,
    //        coordsType: String? = nil,
    //        gridX: Int? = nil,
    //        gridY: Int? = nil,
    //        gridZ: Int? = nil,
    //        hasColRowCoords: Bool? = nil,
    //        hasGridCoords: Bool? = nil,
    //        idi: Int? = nil,
    //        idj: Int? = nil,
    //        idk: Int? = nil,
    //        name: String? = nil,
    //        ngx: Int? = nil,
    //        ngy: Int? = nil,
    //        ngz: Int? = nil,
    //        structName: String? = nil
    //    ) -> QVecDim {
    //        return QVecDim(
    //            qDataType: qDataType ?? self.qDataType,
    //            qOutputLength: qOutputLength ?? self.qOutputLength,
    //            binFileSizeInStructs: binFileSizeInStructs ?? self.binFileSizeInStructs,
    //            coordsType: coordsType ?? self.coordsType,
    //            gridX: gridX ?? self.gridX,
    //            gridY: gridY ?? self.gridY,
    //            gridZ: gridZ ?? self.gridZ,
    //            hasColRowCoords: hasColRowCoords ?? self.hasColRowCoords,
    //            hasGridCoords: hasGridCoords ?? self.hasGridCoords,
    //            idi: idi ?? self.idi,
    //            idj: idj ?? self.idj,
    //            idk: idk ?? self.idk,
    //            name: name ?? self.name,
    //            ngx: ngx ?? self.ngx,
    //            ngy: ngy ?? self.ngy,
    //            ngz: ngz ?? self.ngz,
    //            structName: structName ?? self.structName
    //        )
    //    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }

    
    public func write(to dir: URL) throws {
        let json:String = try jsonString()!

        try json.write(to: dir, atomically: true, encoding: .utf8)
    }


}





