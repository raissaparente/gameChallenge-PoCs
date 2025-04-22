//
//  EffectModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 22/04/25.
//
import Foundation

enum EffectType: String, Codable, CaseIterable, Identifiable {
    case memory, health, courage, affection, wisdom, charm, strength, sanity
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .memory: return "memória"
        case .health: return "saúde"
        case .courage: return "coragem"
        case .affection: return "afeto"
        case .wisdom: return "sabedoria"
        case .charm: return "charme"
        case .strength: return "força"
        case .sanity: return "sanidade"
        }
    }
}

struct IngredientEffect: Codable, Identifiable {
    let type: EffectType
    var isPositive: Bool
    
    var id: String { "\(type.rawValue)-\(isPositive)" }
    
    var points: Int {
        isPositive ? 1 : -1
    }
    
    var effectText: String {
        let verb = isPositive ? "Aumenta" : "Diminui"
        return "\(verb) sua \(type.description)"
    }
    
    mutating func toggle() {
        isPositive.toggle()
    }
}
