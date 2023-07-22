//
//  Interrupting.swift
//  
//
//  Created by Nate Rivard on 10/07/2023.
//

import Foundation

public enum InterruptStatus {
    /// Device is not interrupting
    case none

    /// Device is interrupting and is non-maskable
    case nonMaskable

    /// Device is interrupting but is maskable
    case maskable
}

/// Simple protocol that seeks to answer the question: are you holding either interrupt line low?
/// ISR will be called repeatedly while _any_ device is holding a line low and interrupt conditions are met
public protocol Interrupting {
    /// Device returns an interrupt status
    var interruptStatus: InterruptStatus { get }
}
