//
//  DetailsView.swift
//  Fiesta
//
//  Created by JOAO PEDRO VALDERRAMA DOS SANTOS on 05/11/24.
//

import SwiftUI


let mockListings: [Listing] = [
    Listing(
        id: "1",
        created_at: "2024-10-01T10:00:00Z",
        animal_name: "Max",
        animal_age: "2",
        description: "Um cachorro amigável e cheio de energia. Adora brincar no parque.",
        size: "Médio",
        photo_url: "https://fastly.picsum.photos/id/10/2500/1667.jpg?hmac=J04WWC_ebchx3WwzbM-Z4_KC_LeLBWr5LZMaAkWkF68",
        localization: "São Paulo, SP",
        specie_id: "dog",
        breed_id: "labrador",
        user_id: "user1",
        sex: "Macho"
    ),
    Listing(
        id: "2",
        created_at: "2024-10-03T11:30:00Z",
        animal_name: "Luna",
        animal_age: "1",
        description: "Gata fofa e carinhosa, adora um cafuné.",
        size: "Pequeno",
        photo_url: "https://example.com/photo2.jpg",
        localization: "Rio de Janeiro, RJ",
        specie_id: "cat",
        breed_id: "persa",
        user_id: "user2",
        sex: "Fêmea"
    ),
    Listing(
        id: "3",
        created_at: "2024-10-04T14:45:00Z",
        animal_name: "Bobby",
        animal_age: "4",
        description: "Cachorro de médio porte, muito leal e protetor.",
        size: "Médio",
        photo_url: "https://example.com/photo3.jpg",
        localization: "Belo Horizonte, MG",
        specie_id: "dog",
        breed_id: "bulldog",
        user_id: "user3",
        sex: "Macho"
    ),
    Listing(
        id: "4",
        created_at: "2024-10-06T08:00:00Z",
        animal_name: "Mimi",
        animal_age: "3",
        description: "Gata tranquila, adora dormir em lugares quentes.",
        size: "Pequeno",
        photo_url: "https://example.com/photo4.jpg",
        localization: "Curitiba, PR",
        specie_id: "cat",
        breed_id: "siamesa",
        user_id: "user4",
        sex: "Fêmea"
    ),
    Listing(
        id: "5",
        created_at: "2024-10-07T15:20:00Z",
        animal_name: "Charlie",
        animal_age: "5",
        description: "Cachorro gentil, ótimo com crianças e outros animais.",
        size: "Grande",
        photo_url: "https://example.com/photo5.jpg",
        localization: "Porto Alegre, RS",
        specie_id: "dog",
        breed_id: "golden retriever",
        user_id: "user5",
        sex: "Macho"
    )
]

struct DetailsView: View {
    
    var currentAnimal = mockListings[0];
    var body: some View {
        VStack(alignment: .leading, content: {
            
                AsyncImage(url:URL(string:currentAnimal.photo_url)){phase in
                    switch(phase){
                        case .success(let image):
                            image
                            .resizable()
                            .scaledToFit()
                            .frame(width:300, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        Spacer().frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                        case .empty:
                            Text("")
                        case .failure(_):
                            Text("")
                        @unknown default:
                            Text("")
                        }
                    }
                
                Text(currentAnimal.animal_name)
            }
        )
    }
}

#Preview {
    DetailsView()
}
