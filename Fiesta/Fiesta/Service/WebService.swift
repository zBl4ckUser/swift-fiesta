//
//  WebService.swift
//  Fiesta
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.


import Foundation
import UIKit

struct WebService{
    let baseURL = "http://localhost:1824"

    func downloadImage(from imageURL:String) async throws -> UIImage? {
        guard let url = URL(string:imageURL) else {
            print("Erro na URL!!!!")
            return nil
        }
        //(req,resp) = tupla recebida da api
        let (data,_) = try await URLSession.shared.data(from: url)
        
        return UIImage(data:data)
    }
    
    func getAllListings() async throws -> [Listing]? {
        
        //endpoint = rota no NodeJS
        // Vai pegar as 15 listagens mais recentes
        let endpoint = baseURL + "/l/recent"
        
        //Verifica se a rota existe
        guard let url = URL(string: endpoint) else {
            print("Erro na URL!!")
            return nil
        }
        
        //Usando o endpoint, fazer comunicação com o NodeJS
        //A comunicação é retornada em uma tupla (req,res)
        // data = req
        // como não terá res, coloca _
        // data deve conter todos os bytes retornados do NodeJS
        let (data,_) = try await URLSession.shared.data(from: url)
        
        // specialists recebe os bytes de data e transforma em JSON
        let specialists = try
            JSONDecoder().decode([Listing].self, from: data)
            return specialists
    }
    
}


//guard = garante que os dados foram recebido de forma correta

/*
 a) guard = como instrução de verificação
 evitar o aninhamentode if else excessivo, usando código limpo
 
 func verificaIdade(idade:Int?){
 
    guard let idade = idade, idade>=18 else {
                        print("Idade inválida ou menor de 18.")
                        return
    }
    print("Vc é maior de idade!")
 
 }
 
 b) guard = desempacotamento opcional seguro
 
 func processarDados(dados:[String:Any]) {
    
    guard let nome = dados["nome"] as? String
          let idade = dados["idade"] as? Int else {
                        print("Dados incompletos ou inválidos.")
                        return
                    
                      }
    print("Nome: \(nome), Idade: \(idade)")
 
 }
 */
