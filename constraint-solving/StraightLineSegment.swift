//
//  StraightLineSegment.swift
//  constraint-solving
//
//  Created by vvoZokk on 20.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation


class StraightLineSegment: Object {
    var activeConstraints: Int = 0
    override var constraints: [Constraint] {
        didSet {
            activeConstraints = 0
            for c in constraints {
                if c.type != .none {
                    activeConstraints += 1
                }
            }
        }
    }
    var vectorX: [Double]
    var vectorB: [Double] {
        get {
            var vector = Array<Double>()
            for (i, x) in vectorX.enumerated() {
                vector.append(vectorA[i] + p * x)
            }
            return vector
        }
        set {
            var sum = 0.0
            for (i, v) in newValue.enumerated() {
                sum += pow(v - vectorA[i], 2)
            }
            p = sqrt(sum)
            for (i, v) in newValue.enumerated() {
                vectorX[i] = (v - vectorA[i]) / p
            }
        }
    }

    override init(dimension: Int) {
        vectorX = Array(repeating: 0.0, count: dimension - 1); vectorX += [1.0]
        super.init(dimension: dimension)
        constraints = Array<Constraint>(repeating: Constraint(), count: dimension + 1)
    }

    override func getGradient(offset: Int) -> [([Double]) -> Double] {
        var functions = Array<([Double]) -> Double>()
        var f = { (_: [Double]) -> Double in
            return 0.0
        }
        let correcton: Int
        // it's bad solution
        if activeConstraints != dim + 1 {
            var count = 0
            for i in 0..<dim+1-activeConstraints {
                if !checkConstraint(i) {
                    count += 1
                }
            }
            correcton = count
        } else {
            correcton = 0
        }

        for i in 0..<2*dim+2+activeConstraints {
            switch i {
            case 0..<dim: // first point coordinates
                f = { (x: [Double]) -> Double in
                    let c: Double
                    if self.checkConstraintX(i) {
                        c = x[offset + i + 2 * self.dim + 2 - correcton]
                    } else {
                        c = 0.0
                    }
                    return 2 * (x[offset + i] - self.vectorA[i]) + c
                }
            case dim..<2*dim: // second point coordinates
                f = { (x: [Double]) -> Double in
                    let a = 2 * (x[offset + i] - self.vectorX[i - self.dim])
                    let b = 2 * x[offset + i] * x[offset + 2 * self.dim + 1]
                    let c = 0.0
                    return a + b + c
                }
            case 2 * dim: // parameter
                f = { (x: [Double]) -> Double in
                    let c: Double
                    if self.checkConstraintP(self.dim) {
                        c = x[offset + 2 * self.dim + 4 - correcton]
                    } else {
                        c = 0.0
                    }
                    return 2 * (x[offset + 2 * self.dim] - self.p) + c
                }
            case 2 * dim + 1: // lambda
                f = { (x: [Double]) -> Double in
                    var sum = 0.0
                    for j in 0..<self.dim {
                        sum += pow(x[offset + j + self.dim], 2)
                    }
                    return sum - 1
                }
            default:
                let j = i - (2 * dim + 2 - correcton)
                if checkConstraintX(j) {
                    f = { (x: [Double]) -> Double in
                        return x[offset + j] - self.constraints[j].value
                    }
                }
                if checkConstraintP(dim) {
                    f = { (x: [Double]) -> Double in
                        return x[offset + 2 * self.dim] - self.constraints[j].value
                    }
                }
            }
            functions.append(f)
        }

        return functions
    }

    override func getHessian(offset: Int) -> [[([Double]) -> Double]] {
        var functions = Array<[([Double]) -> Double]>()
        let nullFunction = { (_: [Double]) -> Double in
            return 0.0
        }
        let correcton: Int
        // it's bad solution
        if activeConstraints != dim + 1 {
            var count = 0
            for i in 0..<dim+1-activeConstraints {
                if !checkConstraint(i) {
                    count += 1
                }
            }
            correcton = count
        } else {
            correcton = 0
        }

        for i in 0..<2*dim+2+activeConstraints {
            var line = Array<([Double]) -> Double>(repeatElement(nullFunction, count: 2 * dim + 2 + activeConstraints))
            for j in 0..<2*dim+2+activeConstraints {
                switch i {
                case 0..<dim:
                    switch j {
                    case 0..<dim:
                        if i == j {
                            line[j] = { (x: [Double]) -> Double in
                                return 2
                            }
                        }
                    case dim..<2*dim+2:
                        break
                    default:
                        let k = j - (2 * dim + 2 - correcton)
                        if i == k {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    }
                case dim..<2*dim:
                    switch j {
                    case dim..<2*dim:
                        if i == j {
                            line[j] = { (x: [Double]) -> Double in
                                return 2 + 2 * x[offset + 2 * self.dim + 1]
                            }
                        }
                    case 2 * dim + 1:
                        line[j] = { (x: [Double]) -> Double in
                            return 2 * x[offset + i]
                        }
                    default:
                        break
                    }
                case 2 * dim:
                    switch j {
                    case 2 * dim:
                        line[j] = { (x: [Double]) -> Double in
                            return 2
                        }
                    default:
                        if j == 2 * dim + 4 - correcton {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    }
                case 2 * dim + 1:
                    switch j {
                    case dim..<2*dim:
                        line[j] = { (x: [Double]) -> Double in
                            return 2 * x[offset + j]
                        }
                    default:
                        break
                    }
                default:
                    switch j {
                    case 0..<dim:
                        let k = i - (2 * dim + 2 - correcton)
                        if j == k {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    default:
                        let k = i - (2 * dim + 2 - correcton)
                        if j == 2 * dim && checkConstraintP(k) {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    }
                }
            }
            functions.append(line)
        }

        return functions
    }

    override func getInitValues(offset: Int) -> [Double] {
        var values = vectorA + vectorX + [p, 0]
        for _ in 0..<activeConstraints {
            values.append(0.0)
        }
        return values
    }

    override func getQuantity() -> Int {
        return 2 * dim + 2 + activeConstraints
    }

    override func getCoordinates() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA + vectorB, id, .straightLineSegment)
    }

    override func setCoordinates(_ coordinates: [Double]) throws {
        if coordinates.count == 2 * dim {
            for i in 0..<2*dim {
                if i < dim {
                    vectorA[i] = coordinates[i]
                } else {
                    vectorB[i - dim] = coordinates[i]
                }
            }
        } else {
            throw BlueprintError.invalidDimension
        }
    }

    override func setParameters(_ parameters: [Double]) throws {
        if parameters.count != 2 * dim + 2 + activeConstraints {
            throw BlueprintError.invalidParameters
        }
        var sum = 0.0
        for i in 0..<dim {
            sum += pow(parameters[dim + i], 2)
        }
        if sqrt(sum) - 1.0 > 1.0e-7 {
            throw BlueprintError.invalidLength
        }
        for i in 0..<dim {
            vectorA[i] = parameters[i]
            vectorX[i] = parameters[dim + i]
        }
        p = parameters[2 * dim]
    }

    override func addConstraint(_ constraint: Constraint, index: Int) throws {
        if index > dim && index < 0 {
            throw BlueprintError.invalidDimension
        }
        switch constraint.type {
        case .constX:
            constraints[index] = constraint
        case .constP:
            constraints[dim] = constraint
        default:
            throw BlueprintError.invalidConstrain
        }
    }

    func checkConstraint(_ index: Int) -> Bool {
        return constraints[index].type != .none
    }

    func checkConstraintX(_ index: Int) -> Bool {
        return constraints[index].type == .constX
    }

    func checkConstraintP(_ index: Int) -> Bool {
        return constraints[index].type == .constP
    }
}

class StraightLineSegment2D: StraightLineSegment {
    required init() {
        super.init(dimension: 2)
    }

    required init(x0: Double, y0: Double, x1: Double, y1: Double) {
        super.init(dimension: 2)
        vectorA = [x0, y0]
        vectorB = [x1, y1]
    }

    override func getCoordinates() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA + vectorB, id, .straightLineSegment2D)
    }
}
