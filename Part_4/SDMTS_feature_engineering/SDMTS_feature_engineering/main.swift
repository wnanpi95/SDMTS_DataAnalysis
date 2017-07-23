//
//  main.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

let bbox_for_buses: Float = 0.001

let myIO = IO(dictionaryPath: CommandLine.arguments[1] as NSString,
              inputFull:  CommandLine.arguments[2] as NSString,
              outputFull: CommandLine.arguments[3] as NSString)

let myStaticDict = StaticDictionaryCollection(resourcePath: myIO.dictionaryPath)
myStaticDict.trips()
myStaticDict.shapes()
myStaticDict.place_patterns()
let myBusContainer = BusEntityContainer(filePath: myIO.inputFull, resource: myStaticDict)
myBusContainer.process(resource: myStaticDict)
myBusContainer.writeOutput(output: myIO.outputFull)

let myPlaceVertices = placeVertexGenerator(resourcePath: myIO.dictionaryPath)
let myPlaceEdges = placeEdgeGenerator(resource: myStaticDict)


