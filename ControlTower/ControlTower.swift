//
//  ControlTower.swift
//  ControlTower
//
//  Created by Nate Bird on 4/19/16.
//  Copyright © 2016 Birdhouse. All rights reserved.
//

typealias Knots = Int

// MARK: Protocols

protocol Flying {
    var descentSpeed: Knots { get }
}

protocol Landing {
    func requestLandingInstructions() -> LandingInstructions
}

protocol Airline: Flying, Landing {
    var type: AirlineType { get }
}

struct LandingInstructions {
    let runway: ControlTower.Runway
    let terminal: ControlTower.Terminal
}

// MARK: Airline Type

protocol AirlineType: Flying {}

enum DomesticAirlineType: AirlineType {
    case Delta
    case American
    case Southwest
}

enum InternationAirlineType: AirlineType {
    case Lufthansa
    case KLM
    case AirFrance
}

// MARK: Control Tower

final class ControlTower {
    enum Runway {
        case R22L
        case L31R
        case M52J
        case B19E
        
        static func runway(speed: Knots) -> Runway {
            switch speed {
                case 0..<91:    return .R22L
                case 91...120:  return .L31R
                case 121...140: return .M52J
                case 141...165: return .B19E
                default:        return .B19E
            }
        }
    }
    
    enum Terminal {
        case A(Int?)
        case B(Int?)
        case C(Int?)
        case International(Int?)
        case Private(Int?)
        
        static func terminal(airline: Airline) -> Terminal {
            let gateManager = GateManager.sharedInstance

            switch  airline.type {
            case is DomesticAirlineType:
                let domesticAirline = airline.type as! DomesticAirlineType
                
                switch domesticAirline {
                    case .Delta:
                        let gate = gateManager.gateFor(.A(nil))
                        return .A(gate)
                    case .American:
                        let gate = gateManager.gateFor(.B(nil))
                        return .B(gate)
                    case .Southwest:
                        let gate = gateManager.gateFor(.C(nil))
                        return .C(gate)
                }
            case is InternationAirlineType:
                let gate = gateManager.gateFor(.International(nil))
                return .International(gate)
            default:
                let gate = gateManager.gateFor(.Private(nil))
                return .Private(gate)
            }
        }
    }
    
    class GateManager {
        
        static let sharedInstance = GateManager()
        
        private init() {}
        
        var gatesForTerminalA: [String: [Int]] = ["occupied": [1,2,3,4,5,6,7,8], "empty": [9,10,11,12]]
        var gatesForTerminalB: [String: [Int]] = ["occupied": [1], "empty": [2,3,4,5,6,7,8]]
        var gatesForTerminalC: [String: [Int]] = ["occupied": [1,2,3,4], "empty": [5,6,7,8,9,10]]
        var gatesForInternationalTerminal: [String: [Int]] = ["occupied": [1,2,3], "empty": [4,5,6]]
        var gatesForPrivateHangars: [String: [Int]] = ["occupied": [1], "empty": [2,3]]
        
        func update(inout gates: [String: [Int]], gate: Int) {
            if var occupiedGates = gates["occupied"] {
                occupiedGates.append(gate)
                gates.updateValue(occupiedGates, forKey: "occupied")
            }
            
            if var emptyGates = gates["empty"], let index = emptyGates.indexOf(gate) {
                emptyGates.removeAtIndex(index)
                gates.updateValue(emptyGates, forKey: "empty")
            }
        }
        
        func emptyGate(inout gates: [String: [Int]]) -> Int? {
            guard let gate = gates["empty"]?.first else { return nil }
            
            update(&gates, gate: gate)
            return gate
        }
        
        func gateFor(terminal: Terminal) -> Int? {
            switch terminal {
            case .A: return emptyGate(&gatesForTerminalA)
            case .B: return emptyGate(&gatesForTerminalB)
            case .C: return emptyGate(&gatesForTerminalC)
            case .International: return emptyGate(&gatesForInternationalTerminal)
            case .Private: return emptyGate(&gatesForPrivateHangars)
            }
        }
    }
    
    func land(airline: Airline) -> LandingInstructions {
        let runway = Runway.runway(airline.descentSpeed)
        let terminal = Terminal.terminal(airline)
        return LandingInstructions(runway: runway, terminal: terminal)
    }
}

extension Airline {
    
    var descentSpeed: Knots {
        return type.descentSpeed
    }
    
    func requestLandingInstructions() -> LandingInstructions {
        return ControlTower().land(self)
    }
}

extension DomesticAirlineType {
    var descentSpeed: Knots {
        return 100
    }
}

extension InternationAirlineType {
    var descentSpeed: Knots {
        return 130
    }
}

struct Flight: Airline {
    var type: AirlineType
}
