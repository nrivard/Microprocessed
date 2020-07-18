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
            case noResolvedAddress
        }

        case implied
        case accumulator
        case stack
        case immediate(value: UInt8)
        case absolute(address: UInt16)
        case absoluteIndexed(address: UInt16, offset: UInt8)
        case absoluteIndexedIndirect(address: UInt16, offset: UInt8)
        case absoluteIndirect(address: UInt16)
        case zeroPage(address: UInt8)
        case zeroPageIndexed(address: UInt8, offset: UInt8)
        case zeroPageIndexedIndirect(address: UInt8, offset: UInt8)
        case zeroPageIndirect(address: UInt8)
        case zeroPageIndirectIndexed(address: UInt8, offset: UInt8)
        case relative(offset: Int8)

        /// this one is quite weird. First, it's a zeropage address to do a test (for BBS• and BBR•)
        /// then, it's a relative address if that test succeeded
        /// to accomplish this, this instruction will return the memory at the zero page address for `.value(::)`
        /// then, it will return relative address for `.address(::)`
        case zeroPageThenRelative(zeroPage: UInt8, relative: Int8)

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

            case Instruction.AddressingMode.Opcodes.absoluteIndirect:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                self = .absoluteIndirect(address: addr)

            case Instruction.AddressingMode.Opcodes.absoluteIndexedIndirect:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.X
                self = .absoluteIndexedIndirect(address: addr, offset: offset)

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

            case Instruction.AddressingMode.Opcodes.zeroPageIndexedIndirect:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.X
                self = .zeroPageIndexedIndirect(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.zeroPageIndirectIndexed:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.Y
                self = .zeroPageIndirectIndexed(address: addr, offset: offset)

            case Instruction.AddressingMode.Opcodes.relative:
                let offset = try memory.read(from: registers.PC + 1)
                self = .relative(offset: Int8(bitPattern: offset))

            case Instruction.AddressingMode.Opcodes.zeroPageThenRelative:
                let zeroPage = try memory.read(from: registers.PC + 1)
                let relative = try memory.read(from: registers.PC + 2)
                self = .zeroPageThenRelative(zeroPage: zeroPage, relative: Int8(bitPattern: relative))

            default:
                throw Instruction.AddressingMode.Error.unknown
            }
        }
    }
}

extension Instruction.AddressingMode {

    /// returns the semantic value, usually fetched from memory
    public func value(from memory: MemoryAddressable, registers: Registers) throws -> UInt8 {
        switch self {
        case .accumulator:
            return registers.A
            
        case .immediate(let value):
            return value

        case .zeroPage, .zeroPageIndexed, .zeroPageIndirect, .zeroPageIndexedIndirect, .zeroPageIndirectIndexed, .absolute, .absoluteIndexed:
            return try memory.read(from: try address(from: memory, registers: registers))

        case .zeroPageThenRelative(let addr, _):
            return try memory.read(from: UInt16(addr))

        case .implied, .stack, .relative, .absoluteIndirect, .absoluteIndexedIndirect:
            throw Error.noAssociatedValue
        }
    }

    /// returns the result address
    public func address(from memory: MemoryAddressable, registers: Registers) throws -> UInt16 {
        switch self {

        case .zeroPage(let addr):
            return UInt16(addr)

        case .zeroPageIndexed(let addr, let offset):
            // supports wraparound addressing
            return UInt16(UInt8(addr &+ offset))

        case .zeroPageIndirect(let addr):
            return try memory.readWord(fromAddressStartingAt:  UInt16(addr))

        case .zeroPageIndexedIndirect(let addr, let offset):
            // supports wraparound addressing in zero page
            //
            // TODO: if first byte is stored at `0xFF`, where should second byte live: 0x100 or 0x000?
            return try memory.readWord(fromAddressStartingAt: UInt16(UInt8(addr &+ offset)))

        case .zeroPageIndirectIndexed(let addr, let offset):
            return try memory.readWord(fromAddressStartingAt: UInt16(addr)) + UInt16(offset)

        case .relative(let offset), .zeroPageThenRelative(_, let offset):
            return UInt16(0xFFFF & Int32(registers.PC) + Int32(offset))

        case .absolute(let addr):
            return addr

        case .absoluteIndexed(let addr, let offset):
            return addr + UInt16(offset)

        case .absoluteIndirect(let addr):
            return try memory.readWord(fromAddressStartingAt: addr)

        case .absoluteIndexedIndirect(let addr, let offset):
            return try memory.readWord(fromAddressStartingAt: addr + UInt16(offset))
            
        case .immediate, .implied, .accumulator, .stack:
            throw Error.noResolvedAddress
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

        case (.zeroPageIndexed(let leftAddr, let leftOffset), .zeroPageIndexed(let rightAddr, let rightOffset)),
             (.zeroPageIndexedIndirect(let leftAddr, let leftOffset), .zeroPageIndexedIndirect(let rightAddr, let rightOffset)),
             (.zeroPageIndirectIndexed(let leftAddr, let leftOffset), .zeroPageIndirectIndexed(let rightAddr, let rightOffset)):
            return leftAddr == rightAddr && leftOffset == rightOffset

        case (.absoluteIndexed(let leftAddr, let leftOffset), .absoluteIndexed(let rightAddr, let rightOffset)),
             (.absoluteIndexedIndirect(let leftAddr, let leftOffset), .absoluteIndexedIndirect(let rightAddr, let rightOffset)):
            return leftAddr == rightAddr && leftOffset == rightOffset

        case (.zeroPageThenRelative(let leftAddr, let leftOffset), .zeroPageThenRelative(let rightAddr, let rightOffset)):
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

extension Instruction.AddressingMode: CustomStringConvertible {

    public var description: String {
        switch self {
        case .implied, .accumulator, .stack:
            return ""
        case .immediate(let value):
            return "#\(value.hex(syntaxParadigm: .assembly))"
        case .zeroPage(let address):
            return address.hex(syntaxParadigm: .assembly)
        case .zeroPageIndirect(let address):
            return "(\(address.hex(syntaxParadigm: .assembly)))"
        case .zeroPageIndexed(let addr, let offset):
            return "\(addr.hex(syntaxParadigm: .assembly)),\(offset.hex(syntaxParadigm: .assembly))"
        case .zeroPageIndexedIndirect(let addr, offset: let offset):
            return "(\(addr.hex(syntaxParadigm: .assembly)),\(offset.hex(syntaxParadigm: .assembly)))"
        case .zeroPageIndirectIndexed(let addr, offset: let offset):
            return "(\(addr.hex(syntaxParadigm: .assembly))),\(offset.hex(syntaxParadigm: .assembly))"
        case .absolute(let addr):
            return addr.hex(syntaxParadigm: .assembly)
        case .absoluteIndirect(let addr):
            return "(\(addr.hex(syntaxParadigm: .assembly)))"
        case .absoluteIndexed(let addr, offset: let offset):
            return "\(addr.hex(syntaxParadigm: .assembly)),\(offset.hex(syntaxParadigm: .assembly))"
        case .absoluteIndexedIndirect(let addr, let offset):
            return "(\(addr.hex(syntaxParadigm: .assembly)),\(offset.hex(syntaxParadigm: .assembly)))"
        case .relative(let offset):
            return "\(offset)"
        case .zeroPageThenRelative(let zp, let relative):
            return "\(zp.hex(syntaxParadigm: .assembly)),\(relative.hex(syntaxParadigm: .assembly))"
        }
    }
}

func ~=<Values: Sequence>(sequence: Values, value: Values.Element) -> Bool where Values.Element: Equatable {
    return sequence.contains(value)
}
