//
//  WebService.swift
//  Fiesta
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.


import Foundation
import UIKit

struct WebService {
    let baseURL = "http://localhost:1824"
    
    // Função para baixar a imagem
    func downloadImage(from imageURL: String) async throws -> UIImage? {
        guard let url = URL(string: imageURL) else {
            print("Erro na URL!!!!")
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return UIImage(data: data)
    }
    
    // Função para obter todas as listagens
    func getListings() async throws -> [Listing]? {
        // Endpoint da API
        let endpoint = baseURL + "/l/recent"
        
        guard let url = URL(string: endpoint) else {
            print("Erro na URL!!")
            return nil
        }
        
        // Fazendo a comunicação com a API
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decodificando a resposta como ListingResponse
        let listingResponse = try JSONDecoder().decode(ListingResponse.self, from: data)
        
        // Retorna o array de listagens
        return listingResponse.data
    }
    
    // Função para obter todas as esp[ecies de animais
    func getSpecies() async throws -> [Specie]? {
        // Endpoint da API
        let endpoint = baseURL + "/search/s/all"
        
        guard let url = URL(string: endpoint) else {
            print("Erro na URL!!")
            return nil
        }
        
        // Fazendo a comunicação com a API
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decodificando a resposta como ListingResponse
        let specieResponse = try JSONDecoder().decode([Specie].self, from: data)
        
        // Retorna o array de listagens
        return specieResponse
    }
    
    func getBreeds(specie_id: String) async throws -> [Breed]? {
        let endpoint = baseURL + "/search/b/fromspecie?specie_id=" + specie_id
        
        guard let url = URL(string: endpoint) else {
            print("Erro na URL!!")
            return nil
        }
        
        // Fazendo a comunicação com a API
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Decodificando a resposta como ListingResponse
        let breedResponse = try JSONDecoder().decode([Breed].self, from: data)
        
        // Retorna o array de listagens
        return breedResponse
    }
}
