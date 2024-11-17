//
//  ListingDetailView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import SwiftUI

struct ListingDetailsView: View {
    var listing: Listing  // Recebe o Listing da HomeView
    
    var service = WebService()
    @State private var listingImage: UIImage?
    
    func downloadImage() async {
        do{
            if let image =  try await service.downloadImage(from: listing.photo_url){
                self.listingImage = image
                }
        } catch {
            print("Ocorreu um erro ao obter a imagem: \(error)")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center){
                    Spacer()
                    if let image = listingImage{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300.0, height: 300.0)
                            .cornerRadius(8.0)
                    }
                    Spacer()
                }
                
                
                
                HStack(){
                    Text("\(listing.animal_name),")
                        .font(.largeTitle)
                        .bold()
                    Text("\(listing.animal_age)")
                        .font(.title2)
                }
                HStack(){
                    Image(systemName: "map")
                    Text("\(listing.localization)")
                        .font(.body)
                    Spacer()
                    Text("Porte \(listing.size)")
                }
                .padding(.horizontal, 8.0)
                HStack{
                    Image(systemName: "pawprint")
                    Text("\(listing.specie.name)")
                        .font(.body)
                    
                    Text("\(listing.breed.name)")
                        .font(.body)
                    
                    Spacer()
                    Text("\(listing.sex)")
                        .font(.body)
                }
                .padding(.horizontal, 8.0)
            
                Divider()
                Text("Descrição")
                    .font(.title3)
                    .bold()
                Text(listing.description)
                    .font(.body)
                    .padding(.horizontal, 8.0)
                }
                .padding()
        }
        .onAppear(){
            Task{
                await downloadImage()
            }
        }
        .navigationTitle("Detalhes do Animal")
    }
}

struct ListingDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailsView(listing: generateExampleListing())
    }
}
