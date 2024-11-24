//
//  WebService.swift
//  Fiesta
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.


import Foundation
import UIKit


//struct que representa o body da requisição para criar uma nova listagem
struct NewListing: Encodable{
    let animal_name: String
    let animal_age: String
    let description: String
    let size: String
    let sex: String
    let photo_url: String
    let localization: String
    let specie_id: String
    let breed_id: String
    let user_id: String
}

struct WebService {
    let baseURL = "http://localhost:1824"
    
    struct ImageUploadResponse: Codable {
        let url: URLResponse

        struct URLResponse: Codable {
            let publicUrl: String
        }
    }
    
    func createListing(listingData: NewListing) async throws{
        guard let url = URL(string: "http://localhost:1824/l") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data = try! JSONEncoder().encode(listingData)
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            print(statusCode)
            if case 200...299 = statusCode{
                print("SUCCESS")
            } else {
                print("FAILURE")
            }
        }
        task.resume()
        print("Listing created successfully")
    }
    
    func uploadImage(imageData: Data) async throws -> String {
        let url = URL(string: "http://localhost:1824/f/")!
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Adiciona os dados da imagem
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        //Adiciona o body do request
        request.httpBody = body
        
        //realiza a requisicao
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Retorna uma exceção se o código de resposta for diferente de 2XX
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        // faz o parse do JSON para pegar o campo publicURL
        let jsonResponse = try JSONDecoder().decode(ImageUploadResponse.self, from: data)
        //retorna a url da imagem
        return jsonResponse.url.publicUrl
    }
    
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
