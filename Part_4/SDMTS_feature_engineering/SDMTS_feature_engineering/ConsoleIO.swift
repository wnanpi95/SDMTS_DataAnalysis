//
//  ConsoleIO.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class IO {
    
    let dictionaryPath: String
    
    let inputFull: String
    let inputShort: String
    let outputFull: String
    let outputShort: String
    
    init(dictionaryPath: NSString, inputFull: NSString, outputFull: NSString) {
        self.dictionaryPath = dictionaryPath as String
        
        self.inputFull = inputFull as String
        self.inputShort = String(inputFull.lastPathComponent)
        
        self.outputFull = outputFull as String
        self.outputShort = String(outputFull.lastPathComponent)
    }
    
}
