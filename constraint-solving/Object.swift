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
        self.dim = dimension
        self.id = Object.count
        self.p = 1
        self.vectorA = Array(repeating: 0.0, count: dimension - 1); vectorA += [1.0]
        self.constraints = Array<Constraint>()

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
    func getParameters() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA, id, .unitVector)
    }
    func setPosition(parameters: [Double]) throws {
        // nothing
    }
    func addConstraint(_ constraint: Constraint, index: Int) throws {
        // nothing
    }
}
