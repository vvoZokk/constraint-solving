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
    
    var dim: Int
    var p: Double
    var vectorA: [Double]
    
    init(dimension: Int) {
        self.dim = dimension
        self.p = 1
        self.vectorA = Array(repeating: 1.0, count: dimension)
    }
    
    internal func getSecondDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double])->Double]) {
        return (0,Array<([Double]) -> Double>())
    }
    internal func getDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double])->Double]) {
        return (0,Array<([Double]) -> Double>())
    }
    internal func getInitValues(offset: Int) -> (dimension: Int, values: [Double]) {
        return (0, Array<Double>())
    }
    
}

class Point2D: Object {
    var constraints: [Constraint]
    var vectorX: [Double] {
        get {
            var vector = Array<Double>(repeating: 0.0, count: dim)
            for i in 0 ..< dim {
                vector[i] = p * vectorA[i]
            }
            return vector
        }
        set {
            var sum = 0.0
            for i in 0 ..< dim {
                sum += newValue[i]
            }
            p = sqrt(sum)
            for i in 0 ..< dim {
                vectorA[i] = newValue[i] / p
            }
        }
    }
    
    required init() {
        // it's so bad...
        self.constraints = Array<Constraint>(repeating: Constraint(), count: 2)
        super.init(dimension: 2)
    }
    
    func newPosition(parameter: Double, direction: [Double]) throws {
        if direction.count != dim {
            throw BluepintError.invalidDimension
        }
        var sum = 0.0
        for i in 0 ..< dim {
            sum += pow(direction[i], 2)
        }
        if sqrt(sum) - 1.0 > 1.0e-12 {
            throw BluepintError.invalidLengh
        }
        p = parameter
        vectorA = direction
    }
    
    override func getDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double]) -> Double]) {
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
        
        return (dim + 2, [da0, da1, dp, dl])
    }
    
    override func getSecondDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double]) -> Double]) {
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
        return (4, m)
    }
    
    override func getInitValues(offset: Int) -> (dimension: Int, values: [Double]) {
        let values = vectorA + [p, 0]
        return(dim + 2, values)
    }
}
