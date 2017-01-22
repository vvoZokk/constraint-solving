//
//  Blueprint.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

enum BlueprintError: Error {
    case invalidConstrain
    case invalidDimension
    case invalidLength
    case invalidObjectKey
    case invalidParameters
}

class Blueprint {
    let accuracy = 1.0e-10
    var objects: [Int: Object]

    init() {
        objects = Dictionary<Int, Object>()
    }

    func add(object: Object) {
        objects[object.id] = object
    }

    func add(constraint: Constraint, index: Int, to id: Int) -> String? {
        do {
            if objects[id] != nil {
                try objects[id]!.addConstraint(constraint, index: index)
                return nil
            } else {
                throw BlueprintError.invalidObjectKey
            }
        } catch BlueprintError.invalidConstrain {
            return "constraint addition error: invalid constraint"
        } catch BlueprintError.invalidObjectKey {
            return "constraint addition error: invalid object's id: \(id)"
        } catch {
            return "constraint addition error"
        }
    }

    private func getHessian(keys: [Int]) throws -> [[([Double]) -> Double]] {
        var result = Array<[([Double]) -> Double]>()
        var globalOffset = 0
        let nullFunction = { (_: [Double]) -> Double in
            return 0
        }
        for key in keys {
            let localHessian = objects[key]?.getHessian(offset: globalOffset)
            if localHessian != nil {
                let dimension = localHessian!.count
                for l in 0..<result.count {
                    result[l] += Array<([Double]) -> Double>(repeating: nullFunction, count: dimension)
                }
                for l in localHessian! {
                    var line = Array<([Double]) -> Double>(repeating: nullFunction, count: globalOffset)
                    line += l
                    result.append(line)
                }
                globalOffset += dimension
            } else {
                throw BlueprintError.invalidObjectKey
            }
        }
        return result
    }

    private func getGradient(keys: [Int]) throws -> [([Double]) -> Double] {
        var result = Array<([Double]) -> Double>()
        var globalOffset = 0
        for key in keys {
            let f = objects[key]?.getGradient(offset: globalOffset)
            if f != nil {
                globalOffset += f!.count
                result += f!
            } else {
                throw BlueprintError.invalidObjectKey
            }
        }
        return result
    }

    private func getInitValues(keys: [Int]) throws -> [Double] {
        var result = Array<Double>()
        var globalOffset = 0
        for key in keys {
            let v = objects[key]?.getInitValues(offset: globalOffset)
            if v != nil {
                globalOffset += v!.count
                result += v!
            } else {
                throw BlueprintError.invalidObjectKey
            }
        }
        return result
    }

    private func findOptimum(keys: [Int]) throws -> [Double] {
        let hessian = try getHessian(keys: keys)
        let gradient = try getGradient(keys: keys)
        var result = try getInitValues(keys: keys)
        var max = 0.0

        if result.count != hessian.count {
            throw BlueprintError.invalidDimension
        }
        if hessian.count != gradient.count {
            throw BlueprintError.invalidDimension
        }
        repeat {
            max = 0.0
            var augmentedMatrix = Array<[Double]>()
            for (i, l) in hessian.enumerated() {
                var line = Array<Double>()
                for f in l {
                    line.append(f(result))
                }
                line.append(-gradient[i](result))
                augmentedMatrix.append(line)
            }
            let iteration = try rowReduction(augmentedMatrix: &augmentedMatrix)

            for (i, delta) in iteration.enumerated() {
                result[i] += delta
                if delta > max {
                    max = delta
                }
            }
        } while max > accuracy
        print(result)

        return result
    }

    private func rowReduction(augmentedMatrix: inout [[Double]]) throws -> [Double] {
        let n = augmentedMatrix.count
        //print(augmentedMatrix)

        func partialPivoting(index: Int) {
            var candidate = fabs(augmentedMatrix[index][index])
            var number = index
            for i in index+1..<n {
                if fabs(augmentedMatrix[i][index]) > candidate {
                    number = i
                    candidate = fabs(augmentedMatrix[i][index])
                }
            }
            if number != index {
                let tmp = augmentedMatrix[index]
                augmentedMatrix[index] = augmentedMatrix[number]
                augmentedMatrix[number] = tmp
            }
        }
        var result = Array<Double>(repeating: 0.0, count: augmentedMatrix.count)
        // forward substitution
        for k in 0..<n-1 {
            partialPivoting(index: k)
            let pivot = augmentedMatrix[k][k]
            for j in 0..<augmentedMatrix[k].count {
                augmentedMatrix[k][j] /= pivot
            }
            for i in k+1..<n {
                let elem = augmentedMatrix[i][k]
                for j in k..<augmentedMatrix[i].count {
                    augmentedMatrix[i][j] -= augmentedMatrix[k][j] * elem
                }
            }
        }
        // back subtitution
        result[n - 1] = augmentedMatrix[n - 1][n] / augmentedMatrix[n - 1][n - 1]
        for k in 0...n-2 {
            let i = n - 2 - k
            result[i] = augmentedMatrix[i][n]
            for j in i+1..<n {
                result[i] -= augmentedMatrix[i][j] * result[j]
            }
        }
        return result
    }

    func calculatePositions() -> String? {
        var keys = Array<Int>()
        var quantities = Array<(key: Int, quantity: Int)>()
        for (k, o) in objects {
            keys.append(k)
            quantities.append((key: k, quantity: o.getQuantity()))
        }
        do {
            var positions = try findOptimum(keys: keys)
            for (key, q) in quantities {
                var position = Array<Double>()
                for _ in 0..<q {
                    position.append(positions.remove(at: 0))
                }
                try objects[key]?.setParameters(position)
            }
            return nil
        } catch BlueprintError.invalidDimension {
            return "position culculation error: invalid dimension"
        } catch BlueprintError.invalidLength {
            return "position culculation error: invalid length of direction vector"
        } catch BlueprintError.invalidParameters {
            return "position culculation error: invalid parameters"
        } catch {
            return "position culculation error"
        }
    }

    func getDisplayedObjects() -> [Int: (type: ObjectType, [Double])] {
        var list = Dictionary<Int, (ObjectType, [Double])>()
        for o in objects.values {
            let (coordinates, id, type) = o.getCoordinates()
            list[id] = (type, coordinates)
        }
        return list
    }

    func setCoordinates(to id: Int, coordinates: [Double]) -> String? {
        do {
            let o = objects[id]
            if o != nil {
                try objects[id]!.setCoordinates(coordinates)
            } else {
                throw BlueprintError.invalidObjectKey
            }
            return nil
        } catch BlueprintError.invalidObjectKey {
            return "coordinates error: invalid object's id: \(id)"
        } catch {
            return "coordinates error: invalid coordinates (object #\(id))"
        }
    }
}
