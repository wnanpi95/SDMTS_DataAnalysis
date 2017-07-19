//
//  StaticDictionaryCollection.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class StaticDictionaryCollection {
    
    let trip_idTOshape_id: [String: String]
    let shape_idTOshapes_array: [String: [Shape]]
    
    init(resourcePath: String) {
        
        
        // MARK: iterating through trips.txt
        let tripsPath = resourcePath+"trips.txt"
        let tripsStringLines =
            readFile(path: tripsPath)?.components(separatedBy: "\r\n")
        let tripsCount = (tripsStringLines?.count)! - 1
        
        // * trip_id -> shape_id
        var tempTrip_idTOshape_id: [String: String] = [:]
        for i in 1..<tripsCount {
            guard let tripsRow =
                tripsStringLines?[i].components(separatedBy: ",") else {
                    continue
            }
            let trip_id = tripsRow[2]
            let shape_id = tripsRow[7]
            tempTrip_idTOshape_id[trip_id] = shape_id
        }
        self.trip_idTOshape_id = tempTrip_idTOshape_id
        // ******************************************************************//
        
        
        // MARK: iterating through shapes.txt
        let shapesPath = resourcePath+"shapes.txt"
        let shapesStringLines =
            readFile(path: shapesPath)?.components(separatedBy: "\r\n")
        let shapesCount = (shapesStringLines?.count)! - 1
        
        // * shape_id -> shapes_array
        var tempShape_idTOshapes_array: [String: [Shape]] = [:]
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
            
            if tempShape_idTOshapes_array[shape_id] == nil {
                tempShape_idTOshapes_array[shape_id] = [shape]
            } else {
                tempShape_idTOshapes_array[shape_id]?.append(shape)
            }
        }
        self.shape_idTOshapes_array = tempShape_idTOshapes_array
        // ******************************************************************//
        
    }
    
}








