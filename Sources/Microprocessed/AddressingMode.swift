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

        /// these are unused opcodes, bucketed by byte size
        case unused1
        case unused2
        case unused3

        /// an internal fixed width (for dumb reasons. to have an aligned grid when mapping to opcodes) mnemonic of addressing modes for quicker resolution
        private enum Mnemonic {
            case absolute
            case a_idx_in
            case a_idx_x_
            case a_idx_y_
            case a_indrct
            case zeropage
            case zp_idx_i
            case zp_idx_x
            case zp_idx_y
            case zp_indct
            case zp_idc_i
            case accumltr
            case implied_
            case stack___
            case immdiate
            case relative
            case zp_reltv
            case unused_1
            case unused_2
            case unused_3
        }

        static private let opcodes: ContiguousArray<Instruction.AddressingMode.Mnemonic> = [
          /* $x0        $x1        $x2       $x3        $x4        $x5        $x6         $x7       $x8        $x9        $xA         $xB        $xC        $xD        $xE       $xF  */
            .stack___, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .stack___, .immdiate, .accumltr, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $0x
            .relative, .zp_idc_i, .zp_indct, .unused_1, .zeropage, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .accumltr, .unused_1, .absolute, .a_idx_x_, .a_idx_x_, .zp_reltv, // $1x
            .absolute, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .stack___, .immdiate, .accumltr, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $2x
            .relative, .zp_idc_i, .zp_indct, .unused_1, .zp_idx_x, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .accumltr, .unused_1, .a_idx_x_, .a_idx_x_, .a_idx_x_, .zp_reltv, // $3x
            .stack___, .zp_idx_i, .unused_2, .unused_1, .unused_2, .zeropage, .zeropage, .zeropage, .stack___, .immdiate, .accumltr, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $4x
            .relative, .zp_idc_i, .zp_indct, .unused_1, .unused_2, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .stack___, .unused_1, .unused_3, .a_idx_x_, .a_idx_x_, .zp_reltv, // $5x
            .stack___, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .stack___, .immdiate, .accumltr, .unused_1, .a_indrct, .absolute, .absolute, .zp_reltv, // $6x
            .relative, .zp_idc_i, .zp_indct, .unused_1, .zp_idx_x, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .stack___, .unused_1, .a_idx_in, .a_idx_x_, .a_idx_x_, .zp_reltv, // $7x
            .relative, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .implied_, .immdiate, .implied_, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $8x
            .relative, .zp_idc_i, .zp_indct, .unused_1, .zp_idx_x, .zp_idx_x, .zp_idx_y, .zeropage, .implied_, .a_idx_y_, .implied_, .unused_1, .absolute, .a_idx_x_, .a_idx_x_, .zp_reltv, // $9x
            .immdiate, .zp_idx_i, .immdiate, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .implied_, .immdiate, .implied_, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $Ax
            .relative, .zp_idc_i, .zp_indct, .unused_1, .zp_idx_x, .zp_idx_x, .zp_idx_y, .zeropage, .implied_, .a_idx_y_, .implied_, .unused_1, .a_idx_x_, .a_idx_x_, .a_idx_y_, .zp_reltv, // $Bx
            .immdiate, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .implied_, .immdiate, .implied_, .implied_, .absolute, .absolute, .absolute, .zp_reltv, // $Cx
            .relative, .zp_idc_i, .zp_indct, .unused_1, .unused_2, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .stack___, .implied_, .unused_3, .a_idx_x_, .a_idx_x_, .zp_reltv, // $Dx
            .immdiate, .zp_idx_i, .unused_2, .unused_1, .zeropage, .zeropage, .zeropage, .zeropage, .implied_, .immdiate, .implied_, .unused_1, .absolute, .absolute, .absolute, .zp_reltv, // $Ex
            .relative, .zp_idc_i, .zp_indct, .unused_1, .unused_2, .zp_idx_x, .zp_idx_x, .zeropage, .implied_, .a_idx_y_, .stack___, .unused_1, .unused_3, .a_idx_x_, .a_idx_x_, .zp_reltv, // $Fx
        ]

        public init(_ opcode: UInt8, memory: MemoryAddressable, registers: Registers) throws {
            let mnemonic = Instruction.AddressingMode.opcodes.withUnsafeBufferPointer { unsafePointer in
                return unsafePointer[Int(opcode)]
            }

            switch mnemonic {
            case .implied_:
                self = .implied

            case .accumltr:
                self = .accumulator

            case .stack___:
                self = .stack

            case .immdiate:
                let value = try memory.read(from: registers.PC + 1)
                self = .immediate(value: value)

            case .absolute:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                self = .absolute(address: addr)

            case .a_idx_x_:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.X
                self = .absoluteIndexed(address: addr, offset: offset)

            case .a_idx_y_:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.Y
                self = .absoluteIndexed(address: addr, offset: offset)

            case .a_indrct:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                self = .absoluteIndirect(address: addr)

            case .a_idx_in:
                let addr = try memory.readWord(fromAddressStartingAt: registers.PC + 1)
                let offset = registers.X
                self = .absoluteIndexedIndirect(address: addr, offset: offset)

            case .zeropage:
                let addr = try memory.read(from: registers.PC + 1)
                self = .zeroPage(address: addr)

            case .zp_idx_x:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.X
                self = .zeroPageIndexed(address: addr, offset: offset)

            case .zp_idx_y:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.Y
                self = .zeroPageIndexed(address: addr, offset: offset)

            case .zp_indct:
                let addr = try memory.read(from: registers.PC + 1)
                self = .zeroPageIndirect(address: addr)

            case .zp_idx_i:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.X
                self = .zeroPageIndexedIndirect(address: addr, offset: offset)

            case .zp_idc_i:
                let addr = try memory.read(from: registers.PC + 1)
                let offset = registers.Y
                self = .zeroPageIndirectIndexed(address: addr, offset: offset)

            case .relative:
                let offset = try memory.read(from: registers.PC + 1)
                self = .relative(offset: Int8(bitPattern: offset))

            case .zp_reltv:
                let zeroPage = try memory.read(from: registers.PC + 1)
                let relative = try memory.read(from: registers.PC + 2)
                self = .zeroPageThenRelative(zeroPage: zeroPage, relative: Int8(bitPattern: relative))

            case .unused_1:
                self = .unused1

            case .unused_2:
                self = .unused2

            case .unused_3:
                self = .unused3
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

        case .implied, .stack, .relative, .absoluteIndirect, .absoluteIndexedIndirect, .unused1, .unused2, .unused3:
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
            
        case .immediate, .implied, .accumulator, .stack, .unused1, .unused2, .unused3:
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
             (.accumulator, .accumulator),
             (.unused1, .unused1),
             (.unused2, .unused2),
             (.unused3, .unused3):
            return true

        default:
            return false
        }
    }
}

extension Instruction.AddressingMode: CustomStringConvertible {

    public var description: String {
        switch self {
        case .implied, .accumulator, .stack, .unused1, .unused2, .unused3:
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
