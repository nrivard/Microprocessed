//
//  File.swift
//  
//
//  Created by Nate Rivard on 30/06/2020.
//

import Foundation

extension UInt16 {

    var truncated: UInt8 {
        return UInt8(0x00FF & self)
    }
}
