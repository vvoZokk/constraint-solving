//
//  Object.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

enum ObjectType {
    case unitVector
    case point
    case straightLineSegment
    case point2D
    case straightLineSegment2D
}

// base class for objects
class Object {
    static var count = 0
    let id: Int
    var dim: Int
    var p: Double
    var vectorA: [Double]
    var constraints: [Constraint]
    
    init(dimension: Int) {
        id = Object.count
        dim = dimension
        p = 1.0
        vectorA = Array(repeating: 0.0, count: dimension - 1); vectorA += [1.0]
        constraints = Array<Constraint>()

        Object.count += 1
    }

    func getGradient(offset: Int) -> [([Double]) -> Double] {
        return Array<([Double]) -> Double>()
    }
    func getHessian(offset: Int) -> [[([Double]) -> Double]] {
        return Array<[([Double]) -> Double]>()
    }
    func getInitValues(offset: Int) -> [Double] {
        return Array<Double>()
    }
    func getQuantity() -> Int {
        return 3
    }
    func getCoordinates() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA, id, .unitVector)
    }
    func setCoordinates(_ coordinates: [Double]) throws {
        // nothing
    }
    func setParameters(_ parameters: [Double]) throws {
        // nothing
    }
    func addConstraint(_ constraint: Constraint, index: Int) throws {
        // nothing
    }
}
