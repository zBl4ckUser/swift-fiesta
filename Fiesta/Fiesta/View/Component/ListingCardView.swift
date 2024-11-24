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
    
    
    //Biaxa a imagem do card para que possa ser exibida
    func downloadImage() async {
        do{
            if let image =  try await service.downloadImage(from: listing.photo_url){
                self.listingImage = image
                }
        } catch {
            print("Ocorreu um erro ao obter a imagem \(error)")
        }
    }
    
    
    var body: some View {
        //Quando clicar no card, o usuário será redirecionado
        //  para a página de detalhes da listagem 
        NavigationLink(destination: ListingDetailsView(listing: listing)){
            VStack(alignment: .leading) {
                HStack(spacing:16.0) {
                    if let image = listingImage{
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 168, height: 168.0)
                            .cornerRadius(8.0)
                            
                    }else{
                        ProgressView()
                        // Mostra um ProgressIndicator
                        //  enquanto a imagem não tiver sido carregada
                    }
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(listing.animal_name)
                            .font(.title)
                            .bold()
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        Text(listing.description)
                            .foregroundColor(.gray)
                            .lineLimit(6)
                    }//fecha VStack interno
                } //fecha o HStack
                .padding(.horizontal, 8.0)
                .padding(.vertical, 8.0)
                
            } //fecha o VStack mais externo
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.lightGray).opacity(0.30))
            .cornerRadius(16.0)
            
        }//fetch
        .onAppear{
            Task{
                await downloadImage()
            }
            
        }
    }
}

// Função para criar uma listagem de exemplo para teste
func generateExampleListing() -> Listing {
    let uuid = UUID().uuidString
    return Listing(
        id: uuid,
        created_at: "2024-11-05T15:00:00Z",
        animal_name: "Rex",
        animal_age: "5 meses",
        description: "Rex é um cachorro amigável e cheio de energia. Adora brincar no parque. laksjdlaksjhdkljashdkjashdkjasdkjahskdjhaskdjhaskjdhaskj",
        size: "Médio",
        photo_url: "https://hsxlzcptowkueotmdimx.supabase.co/storage/v1/object/public/uploads/1731592435065_1000071955.jpg",
        localization: "São Paulo, SP",
        specie_id: uuid,
        breed_id: uuid,
        user_id: uuid,
        sex: "Macho",
        specie: Specie(id: "aakdjjguaygdhgahsgdhgasfdhgasfd", name: "Cachorro"),
        breed: Breed(id: "kahsdjhasgdjhasd", specie_id: "aksjdbaksjhdkajsd", name: "Rottweiler")
    )
}

struct ListingCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Mostra o listing card com o animal de exemplo, no Preview da View
        ListingCardView(listing: generateExampleListing())
    }
}


