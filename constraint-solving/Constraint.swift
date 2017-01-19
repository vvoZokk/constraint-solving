//
//  Constraint.swift
//  constraint-solving
//
//  Created by vvoZokk on 18.01.17.
//  Copyright © 2017 BMSTU. All rights reserved.
//

import Foundation

enum ConstraintType {
    case none   // no consstraints
    case constX // fixed one coordinate for point
    case constP // fixed length for straight line segment
    case constA // fixed angle between two line segments
}

// class for constraints
class Constraint {
    var constraintType: ConstraintType
    var constraintValue: Double
    weak var secondObject: Object?

    init() {
        constraintType = .none
        constraintValue = 0.0
        secondObject = nil
    }

    func changeType(type: ConstraintType, value: Double, relation: Object?) throws {
        switch type {
        // add relation type check for constA
        default:
            constraintType = type
        }
        constraintValue = value
    }
}
