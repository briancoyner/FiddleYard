/*:
 [Home](Welcome) • [Previous page](@previous) • [Next page](@next)
 
 ---
 ## View State Transitions
 
 This example shows how you might handle updating views when the "bound"
 data structure changes (including `nil` values). 
 */

import Foundation
import UIKit

struct Engine {
    let engineID: UInt8
    let name: String
    let roadName: String
}

final class EngineTableViewCellSynchronizer {
    
    private let identifierLabel: UILabel
    private let nameLabel: UILabel
    private let roadNameLabel: UILabel
    
    var engine: Engine? {
        didSet {
            transition(from: oldValue, to: engine)
        }
    }
    
    init(identifierLabel: UILabel, nameLabel: UILabel, roadNameLabel: UILabel) {
        self.identifierLabel = identifierLabel
        self.nameLabel = nameLabel
        self.roadNameLabel = roadNameLabel
    }
}

extension EngineTableViewCellSynchronizer {
    
    private func transition(from: Engine?, to: Engine?) {
        switch (from, to) {
        case (.none, .none):
            break
        case (.none, .some(let newEngine)):
            setUp(newEngine)
        case (.some(let oldEngine), .some(let newEngine)):
            tearDown(oldEngine)
            setUp(newEngine)
        case (.some(_), .none):
            clearInternalViews()
        }
    }
}

extension EngineTableViewCellSynchronizer {
    
    private func tearDown(_ engine: Engine) {
        // May need to remove any delegates, observers, etc.
        
        clearInternalViews()
    }
    
    private func setUp(_ engine: Engine) {
        // May need to add delegates, observers, etc.
        
        identifierLabel.text = "\(engine.engineID)"
        nameLabel.text = engine.name
        roadNameLabel.text = engine.roadName
    }
    
    private func clearInternalViews() {
        identifierLabel.text = nil
        nameLabel.text = nil
        roadNameLabel.text = nil
    }
}

extension EngineTableViewCellSynchronizer: CustomPlaygroundDisplayConvertible {
    
    var playgroundDescription: Any {
        return [
            identifierLabel.text,
            nameLabel.text,
            roadNameLabel.text
        ]
    }
}

let identifierLabel = UILabel()
let nameLabel = UILabel()
let roadNumberLabel = UILabel()

let synchronizer = EngineTableViewCellSynchronizer(identifierLabel: identifierLabel, nameLabel: nameLabel, roadNameLabel: roadNumberLabel)

synchronizer.engine = Engine(engineID: 4, name: "Foo", roadName: "1234")
synchronizer.engine = nil

