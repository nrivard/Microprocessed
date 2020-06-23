//
//  File.swift
//  
//
//  Created by Nate Rivard on 23/06/2020.
//

import Foundation

extension Microprocessor {

    public struct Configuration {
        let allowsUndocumentedInstructions: Bool

        public init(allowsUndocumentedInstructions: Bool) {
            self.allowsUndocumentedInstructions = allowsUndocumentedInstructions
        }
    }
}

extension Microprocessor.Configuration {

    public static let `default`: Microprocessor.Configuration = .init(
        allowsUndocumentedInstructions: false
    )
}
