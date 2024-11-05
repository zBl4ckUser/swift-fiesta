//
//  HomeView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.
//

import SwiftUI

struct HomeView: View {
    let service = WebService()
    @State var listings: [Listing] = []
    
    func getListings() async {
        do{
            if let listings = try await
                service.getAllListings(){
                self.listings = listings
            }
        }catch{
            print("Ocorreu um erro ao obter os especialistas \(error)")
        }
    }
    
    var body: some View {
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
                ForEach(listings){ listing in
                    ListingCardView(listing: listing)
                       .padding(.bottom, 3)
                }
                    
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}

#Preview {
    HomeView()
}
