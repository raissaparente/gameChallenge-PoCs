//
//  PhaseModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 22/04/25.
//
import Foundation

struct Phase {
    let number: Int
    let clients: [Client]
    let clientsUntilNight: Int
    let minXPToNext: Int
    
    var maxXP: Int {
        return clients.count*25
    }

}
