//
//  File.swift
//  
//
//  Created by Nate Rivard on 18/06/2020.
//

import Combine
import Foundation

/// microprocessor unit
///
/// Queries supplied `MemoryAddressable` object for instructions and data.
public class Microprocessor {

    /// Memory layout that the MPU uses to fetch opcodes and data alike
    public unowned let memory: MemoryAddressable

    /// configures the microprocessor
    public let configuration: Configuration

    /// metadata flag
    public private(set) var isRunning = false

    var registers: Registers = .init()

    public required init(memoryLayout memory: MemoryAddressable, configuration: Configuration = .default) {
        self.memory = memory
        self.configuration = configuration
    }

    public func reset() throws {
        registers.PC = try memory.readWord(fromAddressStartingAt: Microprocessor.resetVectorLow)
        registers.A = 0
        registers.X = 0
        registers.Y = 0
        registers.SP = 0xFF
    }

    public func step() throws {
        let instruction = try fetch()

        try execute(instruction)

        // TODO: notify observer(s)
    }

    public func run() throws {
        isRunning = true

        while isRunning {
            try step()
        }
    }

    public func pause() {
        isRunning = false
    }
}

extension Microprocessor {

    func fetch() throws -> Instruction {
        let opcode = try memory.read(from: registers.PC)
        registers.PC += 1

        return try Instruction(opcode)
    }

    func execute(_ instruction: Instruction) throws {

    }
}

extension Microprocessor {

    /// non-maskable interrupt vector. when NMI is encountered, the MPU will request the address of the ISR at this address
    public static let nmiVectorLow: UInt16 = 0xFFFA
    public static let nmiVectorHigh: UInt16 = nmiVectorLow + 1

    /// reset interrupt vector. when a reset occurs, the MPU will request the address for code start at this address
    public static let resetVectorLow: UInt16 = 0xFFFC
    public static let resetVectorHigh: UInt16 = resetVectorLow + 1

    /// interrupt vector. when an interrupt occurs, the MPU will request the address of the ISR at this address
    public static let irqVectorLow: UInt16 = 0xFFFE
    public static let irqVectorHight: UInt16 = irqVectorLow + 1
}

extension Microprocessor {

    public struct Registers {

        /// accumulator
        var A: UInt8 = 0

        /// X index
        var X: UInt8 = 0

        /// Y index
        var Y: UInt8 = 0

        /// Stack pointer offset
        var SP: UInt8 = 0

        /// Status register
        var SR: UInt8 = 0

        /// Program counter
        var PC: UInt16 = 0
    }
}
