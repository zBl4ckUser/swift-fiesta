//
//  ListingResponse.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import Foundation


// A resposta do getAllListings vem como um array de Listings,
//  então isolamos a resposta nessa struct
struct ListingResponse: Codable {
    let data: [Listing]
}
