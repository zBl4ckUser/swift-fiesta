//
//  HomeView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.
//

import SwiftUI

struct HomeView: View {
    let service = WebService()
    @State private var listings: [Listing] = []
    
    // Função para obter as listagens
    func getListings() async {
        do {
            if let listings = try await service.getAllListings() {
                self.listings = listings
            }
        } catch {
            print("Ocorreu um erro ao obter as listagens: \(error)")
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    Text("Seja bem-vindo(a)!")
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.blue)
                    Text("Listagens de animais a adoção")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color .accentColor)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)
                    
                    NavigationLink(destination: NewListingView()) {
                        Text("Cadastrar animal")  // Aqui, você pode usar o Text ou Button
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.title2)
                    }
                    .padding(.bottom, 20)
                        // Mostra os cards das listagens
                    ForEach(listings){ listing in
                        ListingCardView(listing: listing)
                            .padding(.bottom, 3)
                    }
                    
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear(){
            Task {
                await getListings()
            }
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
