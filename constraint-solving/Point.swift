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
                if c.constraintType == ConstraintType.constX {
                    activeConstraints += 1
                }
            }
        }
    }
    var vectorX: [Double] {
        get {
            var vector = Array<Double>()
            for a in vectorA {
                vector.append(p * a)
            }
            return vector
        }
        set {
            var sum = 0.0
            for v in newValue {
                sum += v
            }
            p = sqrt(sum)
            for (i, v) in newValue.enumerated() {
                vectorA[i] = v / p
            }
        }
    }
    
    override init(dimension: Int) {
        super.init(dimension: dimension)
        constraints = Array<Constraint>(repeating: Constraint(), count: dimension)
    }
    
    override func setPosition(parameters: [Double]) throws {
        if parameters.count != dim + 2 + activeConstraints {
            throw BluepintError.invalidParameters
        }
        var sum = 0.0
        for i in 0..<dim {
            sum += pow(parameters[i], 2)
        }
        if sqrt(sum) - 1.0 > 1.0e-7 {
            throw BluepintError.invalidLengh
        }
        for i in 0..<dim {
            vectorA[i] = parameters[i]
        }
        p = parameters[dim]
    }
    
    override func getGradient(offset: Int) -> [([Double]) -> Double] {
        var functions = Array<([Double]) -> Double>()
        var f = { (_: [Double]) -> Double in
            return 0.0
        }
        let correcton: Int
        if dim != activeConstraints && checkConstraint(index: 0) {
            correcton = 0
        } else {
            correcton = dim - activeConstraints
        }
        print(correcton, activeConstraints)

        for i in 0..<dim + 2 + activeConstraints {
            switch i {
            case 0..<dim: // coordinates
                f = { (x: [Double]) -> Double in
                    let a = 2 * (x[offset + i] - self.vectorA[i])
                    let b = 2 * x[offset + i] * x[offset + self.dim + 1]
                    var c = 0.0
                    if self.checkConstraint(index: i) {
                        c = x[offset + self.dim] * x[offset + i + self.dim + 2 - correcton]
                    }
                    return a + b + c
                }
            case dim: // parameter
                f = { (x: [Double]) -> Double in
                    var a = 0.0
                    for j in 0..<self.constraints.count {
                        if self.checkConstraint(index: j) {
                            a += x[offset + j] * x[offset + j + self.dim + 2 - correcton]
                        }
                    }
                    return 2 * (x[offset + self.dim] - self.p) + a
                }
            case dim + 1: // lambda
                f = { (x: [Double]) -> Double in
                    var sum = 0.0
                    for j in 0..<self.dim {
                        sum += pow(x[offset + j], 2)
                    }
                    return sum - 1
                }
            default:
                let j = i - (self.dim + 2 - correcton)
                f = { (x: [Double]) -> Double in
                    return x[offset + j] * x[offset + self.dim] - self.constraints[j].constraintValue
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
        if dim != activeConstraints && checkConstraint(index: 0) {
            correcton = 0
        } else {
            correcton = dim - activeConstraints
        }

        for i in 0..<dim + 2 + activeConstraints {
            var line = Array<([Double]) -> Double>(repeatElement(nullFunction, count: dim + 2 + activeConstraints))
            for j in 0..<dim + 2 + activeConstraints {
                switch i {
                case 0..<dim:
                    switch j {
                    case 0..<dim:
                        if i == j {
                            line[j] = { (x: [Double]) -> Double in
                                return 2 + 2 * x[offset + self.dim + 1]
                            }
                        }
                    case dim:
                        if self.checkConstraint(index: i) {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + i + self.dim + 2 - correcton]
                            }
                        }
                    case dim + 1:
                        line[j] = { (x: [Double]) -> Double in
                            return 2 * x[offset + i]
                        }
                    default:
                        let k = j - (dim + 2 - correcton)
                        if i == k {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + self.dim]
                            }
                        }
                    }
                case dim:
                    switch j {
                    case 0..<dim:
                        if checkConstraint(index: j) {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + j + self.dim + 2 - correcton]
                            }
                        }
                    case dim:
                        line[j] = { (x: [Double]) -> Double in
                            return 2
                        }
                    case dim + 1:
                        break
                    default:
                        let k = j - (dim + 2 - correcton)
                        if checkConstraint(index: k) {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + k]
                            }
                        }
                    }
                case dim + 1:
                    switch j {
                    case 0..<dim:
                        line[j] = { (x: [Double]) -> Double in
                            return 2 * x[offset + j]
                        }
                    default:
                        break
                    }
                default:
                    switch j {
                    case 0..<dim:
                        let k = i - (dim + 2 - correcton)
                        if j == k {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + self.dim]
                            }
                        }
                    case dim:
                        let k = i - (dim + 2 - correcton)
                        if checkConstraint(index: k) {
                            line[j] = { (x: [Double]) -> Double in
                                return x[offset + k]
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
        var values = vectorA + [p, 0]
        for _ in 0..<activeConstraints {
            values.append(0.0)
        }
        return values
    }
    
    override func getQuantity() -> Int {
        return dim + 2 + activeConstraints
    }

    override func addConstraint(constraint: Constraint, index: Int) throws {
        constraints[index] = constraint
    }

    func checkConstraint(index: Int) -> Bool {
        return constraints[index].constraintType == ConstraintType.constX
    }
}

class Point2D: Point {
    required init() {
        super.init(dimension: 2)
    }
}
