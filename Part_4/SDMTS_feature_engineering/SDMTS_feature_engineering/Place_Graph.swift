//
//  Place_Graph.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/21/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class PlaceVertex {
    let place_id: String
    let place_lat: Float
    let place_long: Float
    
    init(place_id: String, place_lat: Float, place_long: Float) {
        self.place_id = place_id
        self.place_lat = place_lat
        self.place_long = place_long
    }
}

func placeVertexGenerator(resourcePath: String) -> [PlaceVertex] {
    var returnArray: [PlaceVertex] = []
    
    let placesPath = resourcePath+"places.txt"
    let placesStringLines =
        readFile(path: placesPath)?.components(separatedBy: "\r\n")
    let placesCount = (placesStringLines?.count)! - 1
    
    for i in 1..<placesCount {
        guard let placesRow =
            placesStringLines?[i].components(separatedBy: ",") else { continue }
        
        let place_id = placesRow[0]
        let place_lat = Float(placesRow[3])
        let place_long = Float(placesRow[4])
        
        let newPlaceVertex = PlaceVertex(place_id: place_id,
                                         place_lat: place_lat!,
                                         place_long: place_long!)
        
        returnArray.append(newPlaceVertex)
    }
    
    return returnArray
}

class PlaceEdge {
    let source: String
    let sink: String
    
    let shape_id: String
    let startIndex: Int
    let endIndex: Int
    
    let dist_traveled: Float
    
    init(source: String, sink: String,
         shape_id: String, startIndex: Int, endIndex: Int,
         dist_traveled: Float) {
        
        self.source = source
        self.sink = sink
        
        self.shape_id = shape_id
        self.startIndex = startIndex
        self.endIndex = endIndex
        
        self.dist_traveled = dist_traveled
    }
}

func findCandidates(position: Position, shapeSet: [Shape]) -> [Int] {
    var candidateIndices: [Int] = []
    let upperLat = position.latitude + bbox_for_buses
    let lowerLat = position.latitude - bbox_for_buses
    
    let upperLon = position.longitude + bbox_for_buses
    let lowerLon = position.longitude - bbox_for_buses
    
    for (index, shape) in shapeSet.enumerated() {
        
        let lat = shape.latitude
        let lon = shape.longitude
        
        if lat >= lowerLat && lat <= upperLat {
            if lon >= lowerLon && lon <= upperLon {
                candidateIndices.append(index)
            }
        }
    }
    return candidateIndices
    
}
func findShapeIndex_DistTraveled(position: Position, shapeSet: [Shape]) -> (Int?, Float?) {
    
    let candidates = findCandidates(position: position, shapeSet: shapeSet)
    guard candidates.isEmpty == false else { return (nil, nil) }
    
    var sepMin: Float = 9999.9
    var nearestIndex: Int? = nil
    
    
    for index in candidates {
        let shape = shapeSet[index]
        let sepLat = (position.latitude-(shape.latitude))*(position.latitude-(shape.latitude))
        let sepLon = (position.longitude-(shape.longitude))*(position.longitude-(shape.longitude))
        if sepLat+sepLon < sepMin {
            sepMin = sepLat+sepLon
            nearestIndex = index
        }
    }
    
    let dist_traveled = shapeSet[nearestIndex!].dist_travelled
    return (nearestIndex, dist_traveled)
}

func placeEdgeGenerator(resource: StaticDictionaryCollection) -> [PlaceEdge] {
    
    var returnArray: [PlaceEdge] = []
    
    for (shape_id, shapes_array) in resource.shape_idTOshapes_array! {
        
        guard let routeDirection =
            resource.shape_idTOroute_direction?[shape_id]
                else { continue }
        
        guard let place_id_array =
            resource.route_directionTOplace_id_array?[routeDirection]
                else { continue }
        
        var place_idTOshape_index: [String: Int] = [:]
        var place_idTOdist_traveled: [String: Float] = [:]
        for place_id in place_id_array {
            
            guard let place_location = resource.place_idTOposition?[place_id]
                else { continue }
            let (shapeIndex, dist_traveled) =
                findShapeIndex_DistTraveled(position: place_location,
                                            shapeSet: shapes_array)
            
            guard shapeIndex != nil && dist_traveled != nil else { continue }
            
            place_idTOshape_index[place_id] = shapeIndex
            place_idTOdist_traveled[place_id] = dist_traveled
        }
        
        var associatedPlace_id_array: [String] = []
        for (place_id, _) in place_idTOshape_index {
            associatedPlace_id_array.append(place_id)
        }
        
        guard associatedPlace_id_array.isEmpty != true else { continue }
        let count = associatedPlace_id_array.count - 1
        for i in 1..<count {
            
            let source_place_id = associatedPlace_id_array[i]
            let startIndex = place_idTOshape_index[source_place_id]
            let sourceDist_traveled = place_idTOdist_traveled[source_place_id]
            
            let sink_place_id = associatedPlace_id_array[i+1]
            let endIndex = place_idTOshape_index[sink_place_id]
            let sinkDist_traveled = place_idTOdist_traveled[sink_place_id]
            
            let dist_traveled = sinkDist_traveled! - sourceDist_traveled!
            
            let newEdge = PlaceEdge(source: source_place_id, sink: sink_place_id, shape_id: shape_id,
                                    startIndex: startIndex!, endIndex: endIndex!,
                                    dist_traveled: dist_traveled)
            returnArray.append(newEdge)
        }
    }
    
    return returnArray
}

func writePlaceEdges(edgeArray: [PlaceEdge], output: String) {
    let file: FileHandle? = FileHandle(forWritingAtPath: output)
    
    if file != nil {
        let header = ("source,sink,shape_id,startIndex,endIndex,dist_traveled\n" as NSString).data(using: String.Encoding.utf8.rawValue)
        
        file?.write(header!)
        
        for edge in edgeArray {
            
            let line = edge.source+","
                    + edge.sink+","
                    + edge.shape_id+","
                    + String(edge.startIndex)+","
                    + String(edge.endIndex)+","
                    + String(edge.dist_traveled)+"\n"
            
            let newLine = (line as NSString).data(using: String.Encoding.utf8.rawValue)
            
            file?.write(newLine!)
        }
        
        file?.closeFile()
        
    } else {
        print("Ooops! Something went wrong!")
    }
}

