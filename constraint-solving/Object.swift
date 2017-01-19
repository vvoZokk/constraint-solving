//
//  Object.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

// base class for objects
class Object: DataProtocol {
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
        self.vectorA = Array(repeating: 0.0, count: dimension - 1)
        vectorA += [1.0]
        self.constraints = Array<Constraint>()

        Object.count += 1
    }

    func newPosition(parameters: [Double]) throws {
    }
    func addConstraint(constraint: Constraint, index: Int) throws {
    }
    internal func getSecondDerivativesFunc(offset: Int) -> [([Double]) -> Double] {
        return Array<([Double]) -> Double>()
    }
    internal func getDerivativesFunc(offset: Int) -> [([Double]) -> Double] {
        return Array<([Double]) -> Double>()
    }
    internal func getInitValues(offset: Int) -> [Double] {
        return Array<Double>()
    }
    
}

class Point2D: Object {
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
    
    required init() {
        // may be not so bad...
        super.init(dimension: 2)
        constraints = Array<Constraint>(repeating: Constraint(), count: 2)
    }
    
    override func newPosition(parameters: [Double]) throws {
        if parameters.count != dim + 1 {
            throw BluepintError.invalidParameters
        }
        var sum = 0.0
        for i in 0..<dim {
            sum += pow(parameters[i], 2)
        }
        if sqrt(sum) - 1.0 > 1.0e-12 {
            throw BluepintError.invalidLengh
        }
        vectorA = parameters
        p = vectorA.removeLast()
    }
    
    override func getDerivativesFunc(offset: Int) -> [([Double]) -> Double] {
        var functions = Array<([Double]) -> Double>()
        var f = {(_: [Double]) -> Double in
            return 0.0
        }
        for i in 0..<dim + 2 {
            switch i {
            case 0..<dim:
                f = { (x: [Double]) -> Double in
                    let a = 2 * (x[offset + i] - self.vectorA[i])
                    let b = 2 * x[offset + i] * x[offset + self.dim + 1]
                    return a + b
                }
            case dim:
                f = { (x: [Double]) -> Double in
                    return 2 * (x[offset + 2] - self.p)
                }
            default:
                f = { (x: [Double]) -> Double in
                    var sum = 0.0
                    for a in self.vectorA {
                        sum += pow(a, 2)
                    }
                    return sum - 1
                }

            }
            functions.append(f)
        }
        /*
        func da0(x: [Double]) -> Double {
            return 2 * (x[offset] - self.vectorA[0]) + 2 * x[offset] * x[offset + 3]
        }
        func da1(x: [Double]) -> Double {
            return 2 * (x[offset + 1] - self.vectorA[1]) + 2 * x[offset + 1] * x[offset + 3]
        }
        func dp(x: [Double]) -> Double {
            return 2 * (x[offset + 2] - self.p)
        }
        func dl(x: [Double]) -> Double {
            return pow(self.vectorA[0], 2) + pow(self.vectorA[1], 2) - 1
        }
        */
        return functions
    }
    
    override func getSecondDerivativesFunc(offset: Int) -> [([Double]) -> Double] {
        func da02(x: [Double]) -> Double {
            return 2 + 2 * x[offset + 3]
        }
        func da0da1(x: [Double]) -> Double {
            return 0
        }
        func da0dp(x: [Double]) -> Double {
            return 0
        }
        func da0dl(x: [Double]) -> Double {
            return 2 * x[offset]
        }
        
        func da1da0(x: [Double]) -> Double {
            return 0
        }
        func da12(x: [Double]) -> Double {
            return 2 + 2 * x[offset + 3]
        }
        func da1dp(x: [Double]) -> Double {
            return 0
        }
        func da1dl(x: [Double]) -> Double {
            return 2 * x[offset]
        }
        
        func dpda0(x: [Double]) -> Double {
            return 0
        }
        func dpda1(x: [Double]) -> Double {
            return 0
        }
        func dp2(x: [Double]) -> Double {
            return 2
        }
        func dpdl(x: [Double]) -> Double {
            return 0
        }
        
        func dlda0(x: [Double]) -> Double {
            return 2 * x[offset]
        }
        func dlda1(x: [Double]) -> Double {
            return 2 * x[offset + 1]
        }
        func dldp(x: [Double]) -> Double {
            return 0
        }
        func dl2(x: [Double]) -> Double {
            return 0
        }
        
        let m = [
            da02, da0da1, da0dp, da0dl,
            da1da0, da12, da1dp, da1dp,
            dpda0, dpda1, dp2, dpdl,
            dlda0, dlda1, dldp, dl2,
            ]
        return m
    }
    
    override func getInitValues(offset: Int) -> [Double] {
        let values = vectorA + [p, 0]
        return values
    }
}
