//
//  File.swift
//  
//
//  Created by Nate Rivard on 22/07/2020.
//

import Foundation

extension Microprocessor {

    public struct Configuration {
        let warnOnUnusedOpcodes: Bool

        public init(warnOnUnusedOpcodes: Bool = true) {
            self.warnOnUnusedOpcodes = warnOnUnusedOpcodes
        }
    }
}
