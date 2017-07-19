//
//  Primitives.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

struct Shape {
    let latitude: Float
    let longitude: Float
    let dist_travelled: Float
}

struct Position {
    let latitude: Float
    let longitude: Float
}

func -(lhs: Position, rhs: Shape) -> Position {
    return Position(latitude: lhs.latitude - rhs.latitude,
                    longitude: lhs.longitude - rhs.longitude)
}

func -(lhs: Shape, rhs: Shape) -> Shape {
    return Shape(latitude: lhs.latitude - rhs.latitude,
                 longitude: lhs.longitude - rhs.latitude,
                 dist_travelled: lhs.dist_travelled - rhs.dist_travelled)
}

func *(lhs: Shape, rhs: Position) -> Float {
    return lhs.latitude*rhs.latitude + lhs.longitude*rhs.longitude
}

func /(lhs: Position, rhs: Float) -> Position {
    return Position(latitude: lhs.latitude/rhs,
                    longitude: lhs.longitude/rhs)
}

func magnitude(shape: Shape) -> Float {
    return sqrt(shape.latitude*shape.latitude
        + shape.longitude*shape.longitude)
}

func magnitude(position: Position) -> Float {
    return sqrt(position.latitude*position.latitude
        + position.longitude*position.longitude)
}
