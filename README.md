# Microprocessed

A complete 65C02 Microprocessor simulator core written entirely in Swift

## Getting Started

Microprocessed is a Swift package.
First, add it as a swift package dependency in XCode and `import Microprocessed` in any files that need to use it.

```swift
dependencies: [
    .package(url: "git@bitbucket.org:nrivard/microprocessed.git", .upToNextMajor(from: "1.0.0")),
],
```

## Using Microprocessed

There are a two major pieces to Microprocessed that you will have to understand to get use out of this package: memory and execution.

### Memory

The 65C02 processor is a memory-mapped processor.
This means the CPU treats I/O, ROM, RAM, etc. in exactly the same way: you can read data at an address, you can write data to an address.
This makes memory the most important thing you define when using Microprocessed.


Microprocessed's memory model is defined by `MemoryAddressable`

```swift
public protocol MemoryAddressable: AnyObject {

    /// return an 8 bit value for the given 16 bit address
    func read(from address: UInt16) throws -> UInt8

    /// write an 8 bit value to the given 16 bit address
    func write(to address: UInt16, data: UInt8) throws
}
```

The simplest memory model you can define is likely something that simulates "free running", i.e. returning `$EA` (a noop instruction) for every read.
If you were to run this, you would see endless noop instructions and monotonically increasing (until wrap-around occurs!) addresses getting fetched.

```swift
final class FreeRunner: MemoryAddressable {
    func read(from address: UInt16) throws -> UInt8 {
        return 0xEA
    }
    
    func write(to address: UInt16, data: UInt8) throws {
        // ignore
    }
}
```

This isn't very interesting for this system, however, so for something slightly more complex, you can look at the included `TestMemory`.
This class now adds a proper reset vector and allows read and write access, sort of like a simplistic RAM module.

```swift
final class TestMemory: MemoryAddressable {

    var memory: [UInt16: UInt8] = [
        Microprocessor.resetVector: 0x00,
        Microprocessor.resetVectorHigh: 0x80
    ]

    func read(from address: UInt16) throws -> UInt8 {
        return memory[address] ?? 0xEA
    }

    func write(to address: UInt16, data: UInt8) throws {
        memory[address] = data
    }
}
```

Real-world systems have a mix of devices: RAM (read-write), ROM (read-only), I/O with exposed registers, unmapped address space, etc.
With `MemoryAddressable` you are free to to create all of these in any way you wish.
Just keep in mind that `Microprocessor` depends on a single `MemoryAddressable`, so any simulated device nesting structure has to be contained in some object that acts as a router.

```swift
final class DeviceRouter: MemoryAddressable {
    let ram = RAM()     /// you will have to work out how to write these specific devices :)
    let rom = ROM()
    let via = VIA()
    
    func read(from address: UInt16) throws -> UInt8 {
        switch address {
            case 0x0000...0x7FFF:
                try ram.read(from: address)
            case 0x8000...0x8FFF:
                try via.read(from: address)
            case 0x9000...0xFFFF:
                try rom.read(from: address)
        }
    }

    func write(to address: UInt16, data: UInt8) throws {
        switch address {
            case 0x0000.0x7FFF:
                try ram.write(to: address, data: data)
            case 0x8000...0x8FFF:
                try via.write(to: address, data: data)
            case 0x9000...0xFFFF:
                throw DeviceRouterError.readOnly
        }
    }
}
```

### Execution

`Microprocessor` is a fully compliant and tested 65C02 simulated processor core.
This is the class you use to execute instructions fetched from the `MemoryAddressable` you provide.
So to use `Microprocessor`, you have to provide it with some memory.

```swift
final class System {
    let mpu: Microprocessor!
    
    init() {
        // memoryLayout is `unowned` so you can safely provide `self` here
        self.mpu = .init(memoryLayout: self)
    }
}

extension System: MemoryAddressable {
    // you can make this your device router if you want, or just pass it to another type to do that work for you
}
```

Now your `Microprocessor` is all set up to execute instructions.
`Microprocessor` only has a single execution function which acts as a single clock pulse: `tick()`.
Calling `tick()` cause the MPU to fetch an instruction at the current program counter and then execute it.

```swift
try mpu.tick()
```

After executing an instruction, you can query the `Microprocessor` about some of its internal state, including:
* register values via the `registers` property
* the next instruction via `peek()`
* the current run mode (in case a `WAI` or `STP` instruction was executed)

`Microprocessor` also provides some pin-level hardware simulation including:
* `reset()` which will run through the reset process
    * reset the program counter to the value at the reset vector
    * clear register values
    * return run mode to `normal`
* `interrupt()` which will simulate a normal interrupt
* `nonMaskableInterrupt()` which will simulate non-maskable interrupt

Lastly, you can control some aspects of execution via `Microprocessor.Configuration`.
At present, this can control whether unused opcodes throw an error or not.
For education purposes, you likely want to throw an error,but for pure simulation, you may not want to.

## Next Steps

Currently, `Microprocessed` has everything you need to create compelling 65C02 simulation experiences, but it's not perfect.
In the future, it would be great to make some changes to `Microprocessor` including:
* convert `Microprocessor` to an `actor`. 
This will allow calling it from any thread and protecting its internal state
* abstract `Microprocessor` to a protocol so other 8-bit MPUs can be swapped in, including an old NMOS 6502 or a Z80, all with the same calling conventions
* more and better hardware simulation. 
Many of the 65C02 pins aren't really abstracted here so you can't simulate wait states and the like. 
In addition, interrupts should technically be cleared by the devices themselves so there are some subtle bugs here.
* cycle accurate execution. 
The current core does not keep a count of cycles executed so cycle-accurate timing isn't currently possible  

If you'd like to contribute, please submit a pull request.
