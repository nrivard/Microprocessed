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

    /// raw register state
    public internal(set) var registers: Registers = .init()

    /// create a `Microprocessor` with a given memory layout and configuration.
    ///
    /// NOTE: `memoryLayout` is `unowned`, so it is the creator's responsibility to keep
    /// both the created `Microprocessor` and `memoryLayout` strongly referenced
    public required init(memoryLayout memory: MemoryAddressable, configuration: Configuration = .default) {
        self.memory = memory
        self.configuration = configuration
    }

    /// reset the `Microprocessor` register state and load `PC` at the `resetVector` address
    public func reset() throws {
        registers.PC = try memory.readWord(fromAddressStartingAt: Microprocessor.resetVector)
        registers.A = 0
        registers.X = 0
        registers.Y = 0
        registers.SP = 0xFF
    }

    /// send a single clock rising edge pulse to the `Microprocessor`
    public func tick() throws {
        let instruction = try fetch()

        try execute(instruction)

        // TODO: notify observer(s)
    }
}

extension Microprocessor {

    /// fetch an instruction and increment the PC
    func fetch() throws -> Instruction {
        let instruction = try Instruction(memory: memory, registers: registers)
        registers.PC += instruction.size

        return instruction
    }

    /// execute the instruction and update status register
    func execute(_ instruction: Instruction) throws {

    }
}

extension Microprocessor {

    /// non-maskable interrupt vector. when NMI is encountered, the MPU will request the address of the ISR at this address
    public static let nmiVector: UInt16 = 0xFFFA
    public static let nmiVectorHigh: UInt16 = nmiVector + 1

    /// reset interrupt vector. when a reset occurs, the MPU will request the address for code start at this address
    public static let resetVector: UInt16 = 0xFFFC
    public static let resetVectorHigh: UInt16 = resetVector + 1

    /// interrupt vector. when an interrupt occurs, the MPU will request the address of the ISR at this address
    public static let irqVector: UInt16 = 0xFFFE
    public static let irqVectorHight: UInt16 = irqVector + 1
}

extension Microprocessor {

    /// Register state of the `Microprocessor`
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
