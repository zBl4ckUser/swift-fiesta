//
//  Specie.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import Foundation


//REpresenta a espécie do animal
struct Specie: Identifiable, Codable, Hashable{
    let id: String
    let name: String
}
