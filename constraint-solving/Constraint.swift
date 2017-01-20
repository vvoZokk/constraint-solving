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
    var type: ConstraintType
    var value: Double
    weak var secondObject: Object?

    init() {
        type = .none
        value = 0.0
        secondObject = nil
    }

    func changeType(_ type: ConstraintType, value: Double, relation: Object?) throws {
        switch type {
        // add relation type check for constA
        default:
            self.type = type
        }
        self.value = value
    }
}
