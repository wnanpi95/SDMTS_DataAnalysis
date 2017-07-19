//
//  Subroutine.swift
//  SDMTS_feature_engineering
//
//  Created by Will An on 7/19/17.
//  Copyright © 2017 Will An. All rights reserved.
//

import Foundation

func readFile(path: String) -> String? {
    
    let file: FileHandle? = FileHandle(forReadingAtPath: path)
    
    if file != nil {
        // Read all the data
        let data = file?.readDataToEndOfFile()
        
        // Close the file
        file?.closeFile()
        
        // Convert our data to string
        let str = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        return str! as String
        
    }
    else {
        print("Ooops! Something went wrong!")
        return nil
    }
}
