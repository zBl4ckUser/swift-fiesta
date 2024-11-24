//
//  HomeView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.
//

import SwiftUI



/*
 Essa é a view inicial do projeto.
 Nela, existe a mensagem de boas-vindas na parte superior central,
    junto com um botão para criar uma nova listagem de animal.
 Abaixo do botão para criar animal, há os cards das listagens atuais de animais. Ao clicar em uma dessas listagens,
     o usuário será redirecionado para a View ListingDetailView.
    
 */

struct HomeView: View {
    let service = WebService()
    @State private var listings: [Listing] = []
    
    // Função para obter as listagens
    func getListings() async {
        do {
            if let listings = try await service.getListings() {
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
        // o .onAppear vai executar um código quando a View aparecer pela primeira vez
        .onAppear(){
            // `Task` representa uma ação assíncrona a ser realizada
            Task {
                await getListings()
            }
        }
        // para crair o "pull to refresh", o tal do arraste para recarregar
        .refreshable {
            await getListings()
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
