//
//  Point.swift
//  constraint-solving
//
//  Created by vvoZokk on 19.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

// base point class
class Point: Object {
    var activeConstraints: Int = 0
    override var constraints: [Constraint] {
        didSet {
            activeConstraints = 0
            for c in constraints {
                if c.type == ConstraintType.constX {
                    activeConstraints += 1
                }
            }
        }
    }

    override init(dimension: Int) {
        super.init(dimension: dimension)
        constraints = Array<Constraint>(repeating: Constraint(), count: dimension)
    }
    
    override func setParameters(_ parameters: [Double]) throws {
        if parameters.count != dim + activeConstraints {
            throw BluepintError.invalidParameters
        }
        for i in 0..<dim {
            vectorA[i] = parameters[i]
        }
    }
    
    override func getGradient(offset: Int) -> [([Double]) -> Double] {
        var functions = Array<([Double]) -> Double>()
        var f = { (_: [Double]) -> Double in
            return 0.0
        }
        let correcton: Int
        if dim != activeConstraints {
            var count = 0
            for i in 0..<dim-activeConstraints {
                if !checkConstraint(i) {
                    count += 1
                }
            }
            correcton = count
        } else {
            correcton = 0
        }
        print(correcton, activeConstraints)

        for i in 0..<dim+activeConstraints {
            switch i {
            case 0..<dim: // coordinates
                f = { (x: [Double]) -> Double in
                    let c: Double
                    if self.checkConstraint(i) {
                        c = x[offset + i + self.dim - correcton]
                    } else {
                        c = 0.0
                    }
                    return 2 * (x[offset + i] - self.vectorA[i]) + c
                }
            default: // lambda
                let j = i - (dim - correcton)
                f = { (x: [Double]) -> Double in
                    return x[offset + j] - self.constraints[j].value
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
        if dim != activeConstraints {
            var count = 0
            for i in 0..<dim-activeConstraints {
                if !checkConstraint(i) {
                    count += 1
                }
            }
            correcton = count
        } else {
            correcton = 0
        }

        for i in 0..<dim+activeConstraints {
            var line = Array<([Double]) -> Double>(repeatElement(nullFunction, count: dim + activeConstraints))
            for j in 0..<dim+activeConstraints {
                switch i {
                case 0..<dim:
                    switch j {
                    case 0..<dim:
                        if i == j {
                            line[j] = { (x: [Double]) -> Double in
                                return 2
                            }
                        }
                    default:
                        let k = j - (dim - correcton)
                        if i == k {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    }
                default:
                    switch j {
                    case 0..<dim:
                        let k = i - (dim - correcton)
                        if j == k {
                            line[j] = { (x: [Double]) -> Double in
                                return 1
                            }
                        }
                    default:
                        break
                    }
                }
            }
            functions.append(line)
        }

        return functions
    }
    
    override func getInitValues(offset: Int) -> [Double] {
        var values = vectorA
        for _ in 0..<activeConstraints {
            values.append(0.0)
        }
        return values
    }
    
    override func getQuantity() -> Int {
        return dim + activeConstraints
    }

    override func getParameters() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA, id, .point)
    }

    override func addConstraint(_ constraint: Constraint, index: Int) throws {
        if index >= 0 && index < dim {
            if constraint.type == ConstraintType.constX {
                constraints[index] = constraint
            } else {
                throw BluepintError.invalidConstrain
            }
        } else {
            throw BluepintError.invalidDimension
        }
    }

    func setCoordinates(_ coord: [Double]) -> Bool {
        if coord.count == dim {
            vectorA = coord
            return true
        } else {
            return false
        }
    }

    func checkConstraint(_ index: Int) -> Bool {
        return constraints[index].type == ConstraintType.constX
    }
}

class Point2D: Point {
    required init() {
        super.init(dimension: 2)
    }

    override func getParameters() -> ([Double], id: Int, type: ObjectType) {
        return (vectorA, id, .point2D)
    }

    func setCoordinates(x: Double, y: Double) {
        vectorA[0] = x
        vectorA[1] = y
    }
}
