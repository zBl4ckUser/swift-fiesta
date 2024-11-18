//
//  Listing.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.
//

import Foundation

struct Listing: Identifiable, Codable, Hashable{
    let id: String
    let created_at: String
    let animal_name: String
    let animal_age: String
    let description: String
    let size: String
    let photo_url: String
    let localization: String
    let specie_id: String
    let breed_id: String
    let user_id: String
    let sex: String
    let specie: Specie
    let breed: Breed
}
