//
//  CálculoXP.swift
//  HelloSpriteKit
//
//  Created by Raissa Bruna Parente on 19/04/25.
//




func calcularCompatibilidade(
    ingredientes: [Ingredient],
    pedido: Order,
    caldeirao: CauldronEffects
) -> Double {
    guard ingredientes.count == 2 else { return 0.0 }
    
    var ingredientesProcessados = ingredientes
    
    //efeito do caldeirao ja esta sendo feito diretamente no ingrediente
//    for i in 0..<ingredientesProcessados.count {
//        var ingrediente = ingredientesProcessados[i]
//        caldeirao.effect(ingredient: &ingrediente)
//        ingredientesProcessados[i] = ingrediente
//    }
    
    var soma: [EffectType: Int] = [:]
    for ingrediente in ingredientesProcessados {
        if let efeito = ingrediente.activeEffect {
            soma[efeito.type, default: 0] += efeito.points
        }
    }

    var somasIndividuais: [Double] = []

    for efeitoDesejado in pedido.desiredEffects {
        let obtido = soma[efeitoDesejado.type, default: 0]
        let desejado = efeitoDesejado.points
        
        if (desejado >= 0 && obtido >= desejado) || (desejado < 0 && obtido <= desejado) {
            somasIndividuais.append(1.0)
        } else {
            let diff = abs(Double(obtido - desejado))
            let compat = max(0, 1.0 - (diff / Double(abs(desejado))))
            somasIndividuais.append(compat)
        }
    }

    let media = somasIndividuais.reduce(0, +) / Double(somasIndividuais.count)
    return media * 100
}
