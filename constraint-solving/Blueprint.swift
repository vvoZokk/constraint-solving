//
//  Blueprint.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

enum BluepintError: Error {
    case invalidParameters
    case invalidDimension
    case invalidLengh
    case invalidConstrain
}

// very bad naming
protocol DataProtocol {
    func getSecondDerivativesFunc(offset: Int) -> [([Double]) -> Double]
    func getDerivativesFunc(offset: Int) -> [([Double]) -> Double]
    func getInitValues(offset: Int) -> [Double]
}

class Blueprint {
    var objects: [Int: Object]

    init() {
        objects = Dictionary<Int, Object>()
    }

    func add(object: Object) {
        objects[object.id] = object
    }

    func add(constraint: Constraint, index: Int, to: Object){
        do {
            try objects[to.id]?.addConstraint(constraint: constraint, index: index)
        } catch BluepintError.invalidConstrain {

        } catch {

        }
    }

    func getSecondDerivaties() -> [([Double]) -> Double] {
        var result = Array<([Double]) -> Double>()
        var globalOffset = 0
        let nullFunc = { (_: [Double]) -> Double in
            return 0
        }
        for o in objects.values {
            let f = o.getSecondDerivativesFunc(offset: globalOffset)
            let dimension = Int(sqrt(Double(f.count)))
            for i in 0 ..< globalOffset + dimension {
                if i < globalOffset {
                    // it's disgusting... may be [[([Double]) -> Double]]?
                    result.insert(contentsOf: Array<([Double]) -> Double>(repeating: nullFunc, count: dimension), at: globalOffset + i * (globalOffset + dimension))
                } else {
                    let local = dimension * (i - globalOffset)
                    result += Array<([Double]) -> Double>(repeating: nullFunc, count: globalOffset)
                    result += f[local..<(local + dimension)]
                }
            }
            globalOffset += dimension
        }

        return result
    }

    func getDerivaties() -> [([Double]) -> Double] {
        var result = Array<([Double]) -> Double>()
        var globalOffset = 0
        for o in objects.values {
            let f = o.getDerivativesFunc(offset: globalOffset)
            globalOffset += f.count
            result += f
        }
        return result
    }

    func getInitValues() -> [Double] {
        var result = Array<Double>()
        var globalOffset = 0
        for o in objects.values {
            let v = o.getInitValues(offset: globalOffset)
            globalOffset += v.count
            result += v
        }
        return result
    }
}
