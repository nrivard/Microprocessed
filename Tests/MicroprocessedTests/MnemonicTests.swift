import XCTest
@testable import Microprocessed

typealias Mnemonic = Instruction.Mnemonic

final class MnemonicTests: XCTestCase {

    func testOpcodesUnique() throws {
        let allOpcodes: [UInt8] = [
            Mnemonic.Opcodes.lda,
            Mnemonic.Opcodes.ldx,
            Mnemonic.Opcodes.ldy,
            Mnemonic.Opcodes.sta,
            Mnemonic.Opcodes.stx,
            Mnemonic.Opcodes.sty,
            Mnemonic.Opcodes.stz,
            Mnemonic.Opcodes.pha,
            Mnemonic.Opcodes.phx,
            Mnemonic.Opcodes.phy,
            Mnemonic.Opcodes.php,
            Mnemonic.Opcodes.pla,
            Mnemonic.Opcodes.plx,
            Mnemonic.Opcodes.ply,
            Mnemonic.Opcodes.plp,
            Mnemonic.Opcodes.tsx,
            Mnemonic.Opcodes.txs,
            Mnemonic.Opcodes.ina,
            Mnemonic.Opcodes.inx,
            Mnemonic.Opcodes.iny,
            Mnemonic.Opcodes.inc,
            Mnemonic.Opcodes.dea,
            Mnemonic.Opcodes.dex,
            Mnemonic.Opcodes.dey,
            Mnemonic.Opcodes.dec,
            Mnemonic.Opcodes.asl,
            Mnemonic.Opcodes.lsr,
            Mnemonic.Opcodes.rol,
            Mnemonic.Opcodes.ror,
            Mnemonic.Opcodes.and,
            Mnemonic.Opcodes.ora,
            Mnemonic.Opcodes.eor,
            Mnemonic.Opcodes.bit,
            Mnemonic.Opcodes.cmp,
            Mnemonic.Opcodes.cpx,
            Mnemonic.Opcodes.cpy,
            Mnemonic.Opcodes.trb,
            Mnemonic.Opcodes.tsb,
            Mnemonic.Opcodes.rmb,
            Mnemonic.Opcodes.smb,
            Mnemonic.Opcodes.adc,
            Mnemonic.Opcodes.sbc,
            Mnemonic.Opcodes.jmp,
            Mnemonic.Opcodes.jsr,
            Mnemonic.Opcodes.rts,
            Mnemonic.Opcodes.rti,
            Mnemonic.Opcodes.bra,
            Mnemonic.Opcodes.beq,
            Mnemonic.Opcodes.bne,
            Mnemonic.Opcodes.bcc,
            Mnemonic.Opcodes.bcs,
            Mnemonic.Opcodes.bvc,
            Mnemonic.Opcodes.bvs,
            Mnemonic.Opcodes.bmi,
            Mnemonic.Opcodes.bpl,
            Mnemonic.Opcodes.bbr,
            Mnemonic.Opcodes.bbs,
            Mnemonic.Opcodes.clc,
            Mnemonic.Opcodes.cld,
            Mnemonic.Opcodes.cli,
            Mnemonic.Opcodes.clv,
            Mnemonic.Opcodes.sec,
            Mnemonic.Opcodes.sed,
            Mnemonic.Opcodes.sei,
            Mnemonic.Opcodes.tax,
            Mnemonic.Opcodes.tay,
            Mnemonic.Opcodes.txa,
            Mnemonic.Opcodes.tya,
            Mnemonic.Opcodes.noop,
        ].flatMap { $0 }

        let dupes: [UInt8: Int] = allOpcodes.reduce([:]) { seenOpcodes, opcode in
            var nextSeenOpcodes = seenOpcodes

            if let seen = seenOpcodes[opcode] {
                nextSeenOpcodes[opcode] = seen + 1
            } else {
                nextSeenOpcodes[opcode] = 1
            }

            return nextSeenOpcodes
        }
        .filter { $0.1 > 1 }

        XCTAssert(dupes.count == 0, "Found duplicate opcodes: \(dupes.map { String(format: "0x%X", $0.0) })")
    }

    func testLDA() {
        XCTAssert(Mnemonic(0xA1) ~= .lda)
        XCTAssert(Mnemonic(0xA5) ~= .lda)
        XCTAssert(Mnemonic(0xA9) ~= .lda)
        XCTAssert(Mnemonic(0xAD) ~= .lda)
        XCTAssert(Mnemonic(0xB1) ~= .lda)
        XCTAssert(Mnemonic(0xB2) ~= .lda)
        XCTAssert(Mnemonic(0xB9) ~= .lda)
        XCTAssert(Mnemonic(0xBD) ~= .lda)
    }

    func testLDX() {
        XCTAssert(Mnemonic(0xA2) ~= .ldx)
        XCTAssert(Mnemonic(0xA6) ~= .ldx)
        XCTAssert(Mnemonic(0xAE) ~= .ldx)
        XCTAssert(Mnemonic(0xB6) ~= .ldx)
        XCTAssert(Mnemonic(0xBE) ~= .ldx)
    }

    func testLDY() {
        XCTAssert(Mnemonic(0xA0) ~= .ldy)
        XCTAssert(Mnemonic(0xA4) ~= .ldy)
        XCTAssert(Mnemonic(0xAC) ~= .ldy)
        XCTAssert(Mnemonic(0xB4) ~= .ldy)
        XCTAssert(Mnemonic(0xBC) ~= .ldy)
    }

    func testNOP() {
        XCTAssert(Mnemonic(0xEA) ~= .nop)
    }

    func testUndefined() {
        XCTAssert(Mnemonic(0x02) ~= .undefined)
    }
}
