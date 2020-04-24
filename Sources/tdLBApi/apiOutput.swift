//
//  apiOutput.swift
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let output = try Output(json)
//https://app.quicktype.io?share=egPgPZcPgEwTNPPxrDqs

import Foundation






// MARK: - Output
public struct qVecOutputData: Codable {
    public var volume = [Volume]()
    public var ortho2DXY = [Ortho2D]()
    public var ortho2DXZ = [Ortho2D]()
    public var ortho2DYZ = [Ortho2D]()


//    public var angle2D: [Angle2D]

    public init(volume: [Volume], ortho2DXY: [Ortho2D], ortho2DXZ: [Ortho2D], ortho2DYZ: [Ortho2D]){

        self.volume = volume
        self.ortho2DXY = ortho2DXY
        self.ortho2DXZ = ortho2DXZ
        self.ortho2DYZ = ortho2DYZ
    }

    public mutating func add(_ volume: Volume){
        self.volume.append(volume)
    }
    public mutating func add(xy: Ortho2D){
        self.ortho2DXY.append(xy)
    }
    public mutating func add(xz: Ortho2D){
        self.ortho2DXZ.append(xz)
    }
    public mutating func add(yz: Ortho2D){
        self.ortho2DYZ.append(yz)
    }




}


// MARK: Output convenience initializers and mutators

extension qVecOutputData {

    public init(data: Data) throws {
        self = try newJSONDecoder().decode(qVecOutputData.self, from: data)
    }

    public init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }



    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}



// MARK: - Volume
public struct Volume: Codable {
    public var every: Int
    public var from, to: Int

    public init(every:Int, from:Int = 0, to:Int = 0){
        self.every = every
        self.from = from
        self.to = to
    }
}

// MARK: Volume convenience initializers and mutators

extension Volume {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Volume.self, from: data)
    }

    public init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}





// MARK: - Ortho2D
public struct Ortho2D: Codable {
    public var at, every: Int
    public var from, to: Int

    public init(at:Int, every:Int, from:Int = 0, to:Int = 0){
        self.at = at
        self.every = every
        self.from = from
        self.to = to
    }
}

// MARK: Ortho2D convenience initializers and mutators

extension Ortho2D {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Ortho2D.self, from: data)
    }

    public init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}








// MARK: - Angle2D
public struct Angle2D: Codable {
    public var atAngle: tGeomCalc
    public var every: Int
    public var from, to: Int

    public init(atAngle:tGeomCalc, every:Int, from:Int = 0, to:Int = 0){
        self.atAngle = atAngle
        self.every = every
        self.from = from
        self.to = to
    }
}
// MARK: Angle2D convenience initializers and mutators

extension Angle2D {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Angle2D.self, from: data)
    }

    public init(json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}












// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
