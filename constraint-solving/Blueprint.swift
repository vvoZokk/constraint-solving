//
//  Blueprint.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

enum BluepintError: Error {
    case invalidDimension
    case invalidLengh
    case invalidConstrain
}

protocol DataProtocol {
    func getSecondDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double])->Double])
    func getDerivativesFunc(offset: Int) -> (dimension: Int, functions: [([Double])->Double])
    func getInitValues(offset: Int) -> (dimension: Int, values: [Double])
}
