//
//  ListingCardView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 05/11/24.
//

import SwiftUI

struct ListingCardView: View {
    var listing: Listing
    
    var service = WebService()
    @State private var listingImage: UIImage?
    
    func downloadImage() async {
        do{
            if let image =  try await service.downloadImage(
                from: listing.photo_url){
                self.listingImage = image
                }
        } catch {
            print("Ocorreu um erro ao obter a imagem \(error)")
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(spacing:16.0) {
                if let image = listingImage{
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                }
                VStack(alignment: .leading, spacing: 8.0) {
                    
                    Text(listing.animal_name)
                        .font(.title)
                        .bold()
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    Text(listing.description)
                        .foregroundColor(.gray)
                }//fecha VStack interno
            } //fecha o HStack
            .padding(.horizontal, 16.0)
            .padding(.vertical, 8.0)

        } //fecha o VStack mais externo
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.lightGray).opacity(0.30))
        .cornerRadius(16.0)
        .onAppear{
            Task{
                await downloadImage()
            }
        }
    }//fech
}

func generateExampleListing() -> Listing {
    let uuid = UUID().uuidString
    
    return Listing(
        id: uuid,
        created_at: "2024-11-05T15:00:00Z",
        animal_name: "Rex",
        animal_age: "5",
        description: "Rex é um cachorro amigável e cheio de energia. Adora brincar no parque.",
        size: "Médio",
        photo_url: "https://example.com/photo_of_rex.jpg",
        localization: "São Paulo, SP",
        specie_id: uuid,
        breed_id: uuid,
        user_id: uuid,
        sex: "Macho"
    )
}

#Preview {
    ListingCardView(listing: generateExampleListing())
}
