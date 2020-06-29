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
            case incorrectValueType
        }

        case implied
        case accumulator
        case stack
        case immediate(value: UInt8)
        case absolute(address: UInt16)
        case absoluteIndexed(address: UInt16, offset: UInt8)
        case absoluteIndirect(address: UInt16)
        case zeroPage(address: UInt8)
        case zeroPageIndexed(address: UInt8, offset: UInt8)
        case zeroPageIndirect(address: UInt8)
        case relative(offset: Int8)

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

            case Instruction.AddressingMode.Opcodes.absolute:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                self = .absolute(address: addr)

            case Instruction.AddressingMode.Opcodes.absoluteIndexedX:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.X
                self = .absoluteIndexed(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.absoluteIndexedY:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.Y
                self = .absoluteIndexed(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.zeroPage:
                let addr = try memory.read(from: registers.PC + 1)
                self = .zeroPage(address: addr)

            case Instruction.AddressingMode.Opcodes.zeroPageIndexedX:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.X
                self = .zeroPageIndexed(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.zeroPageIndexedY:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.Y
                self = .zeroPageIndexed(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.zeroPageIndirect:
                let addr = try memory.read(from: registers.PC + 1)
                self = .zeroPageIndirect(address: addr)

            case Instruction.AddressingMode.Opcodes.relative:
                let offset = try memory.read(from: registers.PC + 1)
                self = .relative(offset: Int8(bitPattern: offset))

            case Instruction.AddressingMode.Opcodes.absoluteIndirect:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                self = .absoluteIndirect(address: addr)

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

        case .zeroPageIndexed(let addr, let offset):
            return try memory.read(from: UInt16(addr + offset))

        case .zeroPageIndirect(let addr):
            let resolvedAddr = try memory.readWord(fromAddressStartingAt:  UInt16(addr))
            return try memory.read(from: UInt16(resolvedAddr))

        case .absolute(let addr):
            return try memory.read(from: addr)

        case .absoluteIndexed(let addr, let offset):
            return try memory.read(from: addr + UInt16(offset))

        case .implied, .accumulator, .stack:
            throw Error.noAssociatedValue

        case .relative, .absoluteIndirect:
            throw Error.incorrectValueType
        }
    }

    public func word(from memory: MemoryAddressable, registers: Registers) throws -> UInt16 {
        switch self {
        case .relative(let offset):
            return UInt16(Int32(registers.PC) + Int32(offset))

        case .absoluteIndirect(let addr):
            return try memory.readWord(fromAddressStartingAt: addr)

        case .immediate, .zeroPage, .absolute, .zeroPageIndexed, .absoluteIndexed, .zeroPageIndirect:
            throw Error.incorrectValueType

        case .implied, .accumulator, .stack:
            throw Error.noAssociatedValue
        }
    }
}

extension Instruction.AddressingMode: Equatable, Hashable {

    public static func ==(lhs: Instruction.AddressingMode, rhs: Instruction.AddressingMode) -> Bool {
        switch (lhs, rhs) {
        case (.immediate(let left), .immediate(let right)),
             (.zeroPage(let left), .zeroPage(let right)),
             (.zeroPageIndirect(let left), .zeroPageIndirect(let right)):
            return left == right

        case (.relative(let left), .relative(let right)):
            return left == right

        case (.absolute(let left), .absolute(let right)),
             (.absoluteIndirect(let left), .absoluteIndirect(let right)):
            return left == right

        case (.zeroPageIndexed(let leftAddr, let leftOffset), .zeroPageIndexed(let rightAddr, let rightOffset)):
            return leftAddr == rightAddr && leftOffset == rightOffset

        case (.absoluteIndexed(let leftAddr, let leftOffset), .absoluteIndexed(let rightAddr, let rightOffset)):
            return leftAddr == rightAddr && leftOffset == rightOffset

        case (.implied, .implied),
             (.stack, .stack),
             (.accumulator, .accumulator):
            return true

        default:
            return false
        }
    }
}

func ~=<Value: Equatable>(array: [Value], value: Value) -> Bool {
    return array.contains(value)
}
