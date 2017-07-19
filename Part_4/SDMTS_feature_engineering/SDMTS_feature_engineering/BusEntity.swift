//
//  BusEntity.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class BusEntity {
    let route_id: String
    let trip_id: String
    let timestamp: Int
    let latitude: Float
    let longitude: Float
    let vehicle_id: Int
    
    var shape_id: String? = nil
    
    var shapeAdj: Shape? = nil
    var shapeAnte: Shape? = nil
    var shapePost: Shape? = nil
    
    var dist_travelled: Double = Double.nan
    var velocity: Double = Double.nan
    
    init(route_id: String, trip_id: String, timestamp: Int,
         latitude: Float, longitude: Float, vehicle_id: Int) {
        
        self.route_id = route_id
        self.trip_id = trip_id
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.vehicle_id = vehicle_id
        
    }
    
    func getShape_id(resource: [String: String]) {
        self.shape_id = resource[self.trip_id]
    }
    
    func findCandidates(shapeSet: [Shape]) -> [Int] {
        var candidateIndices: [Int] = []
        let upperLat = self.latitude + bbox_for_buses
        let lowerLat = self.latitude - bbox_for_buses
        
        let upperLon = self.longitude + bbox_for_buses
        let lowerLon = self.longitude - bbox_for_buses
        
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
    func findShapes(candidates: [Int], shapeSet: [Shape]) {
        
        guard candidates.isEmpty == false else { return }
        
        var sepMin: Float = 9999.9
        var nearestIndex: Int? = nil
        
        
        for index in candidates {
            let shape = shapeSet[index]
            let sepLat = (self.latitude-(shape.latitude))*(self.latitude-(shape.latitude))
            let sepLon = (self.longitude-(shape.longitude))*(self.longitude-(shape.longitude))
            if sepLat+sepLon < sepMin {
                sepMin = sepLat+sepLon
                nearestIndex = index
            }
        }
        
        
        guard nearestIndex != nil else { return }
        
        self.shapeAdj = shapeSet[nearestIndex!]
        if nearestIndex != 0 {
            self.shapeAnte = shapeSet[nearestIndex!-1]
        }
        if nearestIndex != (shapeSet.count)-1 {
            self.shapePost = shapeSet[nearestIndex!+1]
        }
        
    }
    func getShapes(resource: [String: [Shape]]) {
        guard self.shape_id != nil else { return }
        guard let shapeSet = resource[self.shape_id!] else { return }
        let candidates = findCandidates(shapeSet: shapeSet)
        findShapes(candidates: candidates, shapeSet: shapeSet)
    }
    
    func findParts(shapeAlpha: Shape, shapeBeta: Shape) -> (Float?, Float?) {
        
        let position = Position(latitude: self.latitude,
                                longitude: self.longitude)
        
        let separationVector = shapeBeta - shapeAlpha
        
        let tailVector = position - shapeAlpha
        let leg = separationVector * tailVector
        if leg < 0 { return (nil, nil) }
        
        let tailMagnitude = magnitude(position: tailVector)
        let arm = abs(tailMagnitude*tailMagnitude - leg*leg)
        
        return (leg, arm)
    }
    func getDist_traveled() {
        guard self.shapeAdj != nil else { return }
        
        var legPost: Float? = nil
        var armPost: Float? = nil
        if self.shapePost != nil {
            (legPost, armPost) = findParts(shapeAlpha: self.shapeAdj!,
                                           shapeBeta: self.shapePost!)
        }
        
        var legAnte: Float? = nil
        var armAnte: Float? = nil
        if self.shapeAnte != nil {
            (legAnte, armAnte) = findParts(shapeAlpha: self.shapeAnte!,
                                           shapeBeta: self.shapeAdj!)
        }
        
        if legPost == nil && legAnte == nil {
            self.dist_travelled = Double((self.shapeAdj?.dist_travelled)!)
        } else if legPost != nil && legAnte == nil {
            self.dist_travelled = Double((self.shapeAdj?.dist_travelled)! + legPost!)
        } else if legPost == nil && legAnte != nil {
            self.dist_travelled = Double((self.shapeAdj?.dist_travelled)! + legAnte!)
        } else if legPost != nil && legAnte != nil {
            if armPost! < armAnte! {
                self.dist_travelled = Double((self.shapeAdj?.dist_travelled)! + legPost!)
            } else {
                self.dist_travelled = Double((self.shapeAdj?.dist_travelled)! + legAnte!)
            }
            
        }
        
    }
    
    func process(resource: StaticDictionaryCollection) {
        getShape_id(resource: resource.trip_idTOshape_id)
        getShapes(resource: resource.shape_idTOshapes_array)
        getDist_traveled()
    }
}

class BusEntityContainer {
    let array: [BusEntity]
    let byTrip_id: [String: [BusEntity]]
    
    init(filePath: String, resource: StaticDictionaryCollection) {
        let stringLines =
            readFile(path: filePath)?.components(separatedBy: "\n")
        let busCount = (stringLines?.count)! - 1
        
        var tempArray: [BusEntity] = []
        var tempDict: [String: [BusEntity]] = [:]
        for i in 1..<busCount {
            guard let inStringRow = stringLines?[i].components(separatedBy: ",")
                else { continue }
            let route_id = inStringRow[0]
            let trip_id = inStringRow[1]
            let timestamp = Int(inStringRow[2])!
            let latitude = Float(inStringRow[3])!
            let longitude = Float(inStringRow[4])!
            let vehicle_id = Int(inStringRow[5])!
            
            let newBusEntity = BusEntity(route_id: route_id,
                                         trip_id: trip_id,
                                         timestamp: timestamp,
                                         latitude: latitude,
                                         longitude: longitude,
                                         vehicle_id: vehicle_id)
            newBusEntity.process(resource: resource)
            tempArray.append(newBusEntity)
            
            if newBusEntity.shapeAdj != nil {
                if tempDict[trip_id] == nil {
                    tempDict[trip_id] = [newBusEntity]
                } else {
                    tempDict[trip_id]?.append(newBusEntity)
                }
            }
        }
        self.array = tempArray
        self.byTrip_id = tempDict
    }
    
    func calcVel(bus1: BusEntity, bus2: BusEntity) -> Double {
        return (bus1.dist_travelled-bus2.dist_travelled) / Double(bus1.timestamp-bus2.timestamp)
    }
    func getVels(trip: [BusEntity]) {
        let count = trip.count-1
        if count < 5 {
            return
        }
        
        trip[0].velocity = Double(calcVel(bus1: trip[1], bus2: trip[0]))
        trip.last?.velocity = Double(calcVel(bus1: trip[count], bus2: trip[count-1]))
        
        for i in 1..<count {
            let back = calcVel(bus1: trip[i], bus2: trip[i-1])
            let front = calcVel(bus1: trip[i+1], bus2: trip[i-1])
            
            trip[i].velocity = Double(0.5*(back+front))
        }
        
    }
    
    func process(resource: StaticDictionaryCollection) {
        /*
        for bus in self.array {

        }
         */
        for (_, trip) in self.byTrip_id {
            getVels(trip: trip)
        }
    }
    
    func writeOutput(output: String) {
        let file: FileHandle? = FileHandle(forWritingAtPath: output)
        
        if file != nil {
            let header = ("route,trip_id,timestamp,latitude,longitude,vehicle_id,dist_travelled,velocity\n" as NSString).data(using: String.Encoding.utf8.rawValue)
            
            file?.write(header!)
            
            for bus in self.array {
                
                let line = bus.route_id+","
                    + bus.trip_id+","
                    + String(bus.timestamp)+","
                    + String(bus.latitude)+","
                    + String(bus.longitude)+","
                    + String(bus.vehicle_id)+","
                    + String(bus.dist_travelled)+","
                    + String(bus.velocity)+"\n"
                
                let newLine = (line as NSString).data(using: String.Encoding.utf8.rawValue)
                
                file?.write(newLine!)
            }
            
            file?.closeFile()
            
        } else {
            print("Ooops! Something went wrong!")
        }
    }
}





