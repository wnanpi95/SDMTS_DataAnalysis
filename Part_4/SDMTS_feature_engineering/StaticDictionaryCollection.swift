//
//  StaticDictionaryCollection.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class StaticDictionaryCollection {
    
    let resourcePath: String
    
    // trips.txt
    var trip_idTOshape_id: [String: String]?
    var shape_idTOroute_direction: [String: RouteDirection]?
    
    // shapes.txt
    var shape_idTOshapes_array: [String: [Shape]]?
    
    // places.txt
    var place_idTOposition: [String: Position]?
    
    // place_patterns.txt
    var route_directionTOplace_id_array: [RouteDirection: [String]]?
    
    
    init(resourcePath: String) {
        self.resourcePath = resourcePath
    }
    
    func trips() {
        // MARK: iterating through trips.txt
        let tripsPath = resourcePath+"trips.txt"
        let tripsStringLines =
            readFile(path: tripsPath)?.components(separatedBy: "\r\n")
        let tripsCount = (tripsStringLines?.count)! - 1
        
        // * trip_id -> shape_id
        trip_idTOshape_id = [:]
        shape_idTOroute_direction = [:]
        for i in 1..<tripsCount {
            guard let tripsRow =
                tripsStringLines?[i].components(separatedBy: ",") else {
                    continue
            }
            let route = tripsRow[0]
            let trip_id = tripsRow[2]
            let direction = tripsRow[5]
            let shape_id = tripsRow[7]
            trip_idTOshape_id?[trip_id] = shape_id
            
            let routeDirection = RouteDirection(route: route,
                                                direction: direction)
            shape_idTOroute_direction?[shape_id] = routeDirection
        }
        // ******************************************************************//
    }
    
    func shapes() {
        // MARK: iterating through shapes.txt
        let shapesPath = resourcePath+"shapes.txt"
        let shapesStringLines =
            readFile(path: shapesPath)?.components(separatedBy: "\r\n")
        let shapesCount = (shapesStringLines?.count)! - 1
        
        // * shape_id -> shapes_array
        shape_idTOshapes_array = [:]
        for i in 1..<shapesCount {
            guard let shapesRow =
                shapesStringLines?[i].components(separatedBy: ",") else {
                    continue
            }
            
            let shape_id      = shapesRow[0]
            let latitude      = Float(shapesRow[1])
            let longitude     = Float(shapesRow[2])
            let dist_traveled = Float(shapesRow[4])
            let shape = Shape(latitude: latitude!,
                              longitude: longitude!,
                              dist_travelled: dist_traveled!)
            
            if shape_idTOshapes_array?[shape_id] == nil {
                shape_idTOshapes_array?[shape_id] = [shape]
            } else if shape_idTOshapes_array?[shape_id]?.last?.dist_travelled
                    != shape.dist_travelled {
                shape_idTOshapes_array?[shape_id]?.append(shape)
            }
        }
        // ******************************************************************//
    }
    
    func places() {
        //MARK: iterating through places.txt
        let placesPath = resourcePath+"places.txt"
        let placesStringLines =
            readFile(path: placesPath)?.components(separatedBy: "\r\n")
        let placesCount = (placesStringLines?.count)! - 1
        
        place_idTOposition = [:]
        for i in 1..<placesCount {
            guard let placesRow =
                placesStringLines?[i].components(separatedBy: ",") else { continue }
            
            let place_id = placesRow[0]
            let place_lat = Float(placesRow[3])
            let place_long = Float(placesRow[4])
            let placePosition = Position(latitude: place_lat!,
                                         longitude: place_long!)
            
            place_idTOposition?[place_id] = placePosition
        }
        
    }
    
    func place_patterns() {
        //MARK: iterating through place_patterns.txt
        let place_patternsPath = resourcePath+"place_patterns.txt"
        let place_patternsStringLines =
            readFile(path: place_patternsPath)?.components(separatedBy: "\r\n")
        let place_patternsCount = (place_patternsStringLines?.count)! - 1
        
        route_directionTOplace_id_array = [:]
        for i in 1..<place_patternsCount {
            guard let place_patternsRow =
                place_patternsStringLines?[i].components(separatedBy: ",") else {
                    continue
            }
            
            let route = place_patternsRow[0]
            let direction = place_patternsRow[2]
            let place = place_patternsRow[3]
            
            let routeDirection = RouteDirection(route: route, direction: direction)
            
            if route_directionTOplace_id_array?[routeDirection] == nil {
                route_directionTOplace_id_array?[routeDirection] = [place]
            } else {
                route_directionTOplace_id_array?[routeDirection]?.append(place)
            }
        }
    }

}








