/*:
 [Home](Welcome) • [Previous page](@previous) • [Next page](@next)
 
 ---
 ## Building Lionel Legacy Engine Commands
 
 ### General Goals
 
 This playground page shows a few techniques for building byte-oriented messages using Swift.
 
 This playground covers the following:
 - protocols
 - protocol composition
 - protocol extensions
 - failable initializers
 - memberwise initializers
 - type wrappers
 
 ### Command Protocol
 
 The [Lionel Legacy Command Protocol](http://www.lionel.com/lcs/resources/LCS-LEGACY-Protocol-Spec-v1.22.pdf) is freely available. However, communicating with Lionel's LCS Wi-Fi hardware requires additional proprietary protocols (out of scope).
 
 Commands are represented by a sequence of bytes. In general, the length of the command depends on the hardware.
 Example Lionel hardware:
 - TMCC engines (older, but still viable, technology)
 - Legacy engines (don't let "Legacy" fool you; this is Lionel's modern technology)
 - Base units
 - Layout Control System (LCS) modules
   - Wi-Fi
   - SensorTracks
   - Switch Throw Monitors
   - Block Controllers
   - etc

 This playground looks at sending Legacy engine commands, which, in general, are three bytes.
 
 A simple protocol named `Command` contains an arbitrary sequence of bytes.
*/

import Foundation

protocol Command {
    var message: [UInt8] { get }
}

/*:
 An `EngineAddressableCommand` introduces an `engineID` property. Any command addressing a specific Lionel engine implements this protocol.
 */

protocol EngineAddressableCommand: Command {
    var engineID: EngineID { get }
}

struct EngineID: Equatable {
    
    /// The engine ID (value is between 1 and 99).
    let value: UInt8
    
    /// A failable initializer that constrains the `EngineID` to
    /// values between 1 and 99.
    ///
    /// - Parameter value: the engine ID
    init?(_ value: Int) {
        switch value {
        case 1 ... 99:
            self.value = UInt8(value)
        default:
            return nil
        }
    }
}

/*:
 - Note:
 Starting with Swift 4.1, we don't have to implement the equals function
 because the compiler will synthesize the function for us. Of course, there are situations
 where you'll want or need to write a custom equals function. Checkout [Synthesizing Equatable and Hashable conformance](https://github.com/apple/swift-evolution/blob/master/proposals/0185-synthesize-equatable-hashable.md) for additional details.
 */
extension EngineID {
    static func ==(lhs: EngineID, rhs: EngineID) -> Bool {
        return lhs.value == rhs.value
    }
}

/*:
 To help with debugging we can create a custom debug string based on the engine's integer value.
 */

extension EngineID: CustomPlaygroundDisplayConvertible {
    
    var playgroundDescription: Any {
        return String("Engine ID: \(value)")
    }
}

/*:
 Here's the `LegacyEngineCommand` protocol describing a way to build engine commands.
 See the associated slides for additional details.
 */

protocol LegacyEngineCommand: EngineAddressableCommand {
    var enableBit9: Bool { get }
    var commandField: UInt8 { get }
}

/*:
 A protocol extension provides a default `message` implementation needed by all
 basic engine commands.
 
 Per the command specification:
 - The first byte is always `0xF8` (i.e. engine command)
 - The second byte contains:
   - the engine ID sits in bits 15...10
   - part of the command data sits in bit 9
 - The third byte contains rest of the command/ data to send to the engine
 */

extension LegacyEngineCommand {
    
    var message: [UInt8] {
        var buffer = [UInt8](repeating: 0, count: 3)
        buffer[0] = 0xF8
        buffer[1] = (engineID.value << 1) | (enableBit9 ? 1 : 0)
        buffer[2] = commandField
        
        return buffer
    }
}

/*:
 Now we can start to build out named commands based on the command specification.
 
 Using Swift's memberwise initializers makes it possible to create a `TurnBellOffCommand` like this:
 */

struct TurnBellOffCommand: LegacyEngineCommand {
    let engineID: EngineID
    let enableBit9 = true
    let commandField: UInt8 = 0xF4
}

struct StopEngineCommand: LegacyEngineCommand {
    let engineID: EngineID
    let enableBit9 = false
    let commandField: UInt8 = 0xFB
}

struct TurnBellOnCommand: LegacyEngineCommand {
    let engineID: EngineID
    let enableBit9 = true
    let commandField: UInt8 = 0xF5
}

struct OpenFrontCouplerCommand: LegacyEngineCommand {
    let engineID: EngineID
    let enableBit9 = true
    let commandField: UInt8 = 0x5
}

struct OpenRearCouplerCommand: LegacyEngineCommand {
    let engineID: EngineID
    let enableBit9 = true
    let commandField: UInt8 = 0x6
}

struct DynamicBellCommand: LegacyEngineCommand {
    
    enum Intensity: UInt8 {
        case soft = 1
        case moderate = 2
        case loud = 3
    }
    
    let engineID: EngineID
    let enableBit9 = true
    let intensity: Intensity
    
    var commandField: UInt8 {
        return UInt8(0xF0) | intensity.rawValue
    }
}

/*:
 Now let's create a few commands and dump out the hex string.
 */

extension Data {
    func hexadecimalString() -> String {
        return self
            .map { String(format: "%02X", $0) }
            .joined()
    }
}

func execute(_ command: Command) {
    let commandName = String(describing: command)
    let message = command.message
    let data = Data(bytes: message)
    
    print("\(commandName): \(data.hexadecimalString())")
}

guard let engineID = EngineID(1) else {
    fatalError("Whoops")
}


execute(OpenFrontCouplerCommand(engineID: engineID))
execute(OpenRearCouplerCommand(engineID: engineID))
execute(DynamicBellCommand(engineID: engineID, intensity: .loud))
execute(DynamicBellCommand(engineID: engineID, intensity: .moderate))
execute(DynamicBellCommand(engineID: engineID, intensity: .soft))
