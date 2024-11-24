//
//  Breed.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import Foundation

//Representa a Raça do animal
struct Breed: Identifiable, Codable, Hashable{
    let id: String
    let specie_id: String
    let name: String
}
