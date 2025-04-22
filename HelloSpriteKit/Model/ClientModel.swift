//
//  ClientModel.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 22/04/25.
//
import Foundation

struct Client {
    let name: String
    let imageNames: [String]
    let currentImage: String
    let orders: [Order]
    
    func feedBackString(acceptanceRate: Double) -> String {
        if acceptanceRate < 0.5 {
            return "horrivel, melhore"
        } else if acceptanceRate == 0.5 {
            return "ok"
        } else {
            return "tudoooo, diva <3"
        }
    }
}
