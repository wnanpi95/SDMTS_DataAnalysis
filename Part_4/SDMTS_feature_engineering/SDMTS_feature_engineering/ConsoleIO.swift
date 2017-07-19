//
//  ConsoleIO.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

class IO {
    
    let dictionaryPath: NSString
    
    let inputFull: NSString
    let inputShort: NSString
    let outputFull: NSString
    let outputShort: NSString
    
    init(dictionaryPath: NSString, inputFull: NSString, outputFull: NSString) {
        self.dictionaryPath = dictionaryPath
        
        self.inputFull = inputFull
        self.inputShort = inputFull.lastPathComponent as NSString
        
        self.outputFull = outputFull
        self.outputShort = outputFull.lastPathComponent as NSString
    }
}
