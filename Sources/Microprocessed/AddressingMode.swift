//
//  File.swift
//  
//
//  Created by Nate Rivard on 24/06/2020.
//

import Foundation

extension Instruction {

    public enum AddressingMode {
        public enum Error: Swift.Error {
            case unknown
            case noAssociatedValue
        }

        case implied
        case accumulator
        case stack
        case immediate(value: UInt8)
//        case absolute(address: UInt16)
//        case absoluteIndexed(address: UInt16, offset: UInt8)
//        case absoluteIndirect(address: UInt16)
        case zeroPage(address: UInt8)
//        case zeroPageIndexed(address: UInt8, offset: UInt8)
//        case relative(offset: Int8)

        public init(_ opcode: UInt8, memory: MemoryAddressable, registers: Registers) throws {
            typealias Opcodes = Instruction.AddressingMode.Opcodes

            switch opcode {
            case Opcodes.implied:
                self = .implied
            case Opcodes.accumulator:
                self = .accumulator
            case Opcodes.stack:
                self = .stack
            case Instruction.AddressingMode.Opcodes.immediate:
                let value = try memory.read(from: registers.PC + 1)
                self = .immediate(value: value)
            case Instruction.AddressingMode.Opcodes.zeroPage:
                let addr = try memory.read(from: registers.PC + 1)
                self = .zeroPage(address: addr)
            default:
                throw Instruction.AddressingMode.Error.unknown
            }
        }
    }
}

extension Instruction.AddressingMode {

    public func value(from memory: MemoryAddressable, registers: Registers) throws -> UInt8 {
        switch self {
        case .immediate(let value):
            return value

        case .zeroPage(let addr):
            return try memory.read(from: UInt16(addr))

        case .implied, .accumulator, .stack:
            throw Error.noAssociatedValue
        }
    }
}

extension Instruction.AddressingMode: Equatable, Hashable {

    public static func ==(lhs: Instruction.AddressingMode, rhs: Instruction.AddressingMode) -> Bool {
        switch (lhs, rhs) {
        case (.immediate(let left), .immediate(let right)),
             (.zeroPage(let left), .zeroPage(let right)):
            return left == right
        case (.implied, .implied):
            return true
        default:
            return false
        }
    }
}

func ~=<Value: Equatable>(array: [Value], value: Value) -> Bool {
    return array.contains(value)
}
