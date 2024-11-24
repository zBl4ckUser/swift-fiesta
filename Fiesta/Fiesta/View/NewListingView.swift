//
//  NewListingView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import SwiftUI
import PhotosUI

/*
 Essa tela só é acessível ao usuário se ele apertar o botáo de "Cadastrar animal"
  na página inicial(HomeView).
 Essa tela contém um imagem picker, TextFields e Pickers, para que o usuário
  coloque as informações do usuário que ele quer cadastrar.
 
 */

struct NewListingView: View {
    let service = WebService()
    @State private var errorMsg: [String] = []
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var showConfirmationAlert: Bool = false
    
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool  = false
    @State private var name: String = ""
    @State private var sex: String = "Macho"
    @State private var localization: String = ""
    @State private var age: String = ""
    @State private var size: String = "Médio"
    @State private var breed: String  = ""
    @State private var description: String  = ""
    
    @State private var sizes: [String]  = ["Pequeno","Médio","Grande"]
    //Será usado para armazenar as espécies de animal
    @State private var species: [Specie] = []
    //Será usado para armazenas as raças da espécie desejada
    @State private var breeds: [Breed] = []
    @State private var selectedSpecie: Specie?
    @State private var selectedBreed: Breed?
    
    
    // Função responsável por converter a imagem escolhida no formato Data, que poderá ser mandado na requisição
    func imageToData() -> Data? {
        guard let image = selectedImage else { return nil }
        return image.jpegData(compressionQuality: 0.5) // Converte a imagem para jpegData com qualidade de 50%
    }
    
    // Função responsável por fazer todo o processo de publicar uma nova listagem
    // o @MainActor vai fazer a função ser executada pela thread principal, assim,
    // vai nos permitir usar o self.dismiss()
    @MainActor
    private func handlePublish() async throws{
        if EmptyFields() {
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let imageData = imageToData(),
                  let specie = selectedSpecie,
                  let breed = selectedBreed else {
                errorMsg.append("Selecione uma imagem, espécie e raça")
                showAlert = true
                return
            }
            
            let photoUrl = try await service.uploadImage(imageData: imageData)
            let data = NewListing(
                animal_name: name,
                animal_age: age,
                description: description,
                size: size,
                sex: sex,
                photo_url: photoUrl,
                localization: localization,
                specie_id: specie.id,
                breed_id: breed.id,
                user_id: "2ac8d213-fa8c-476e-a870-b9b79ede6532"
            )
            
            //Cria a listagem do animal
            try await service.createListing(listingData: data)
            //Se tudo der certo, sai da View
            self.dismiss()
        } catch {
            errorMsg.append("Erro ao criar listagem: \(error.localizedDescription)")
            showAlert = true
        }
    }
    
    //Faz o get das espécies "Cachorro, Gato, Ouriço..."
    private func fetchSpecies() async {
        do {
            if let fetchedSpecies = try await service.getSpecies() {
                species = fetchedSpecies
                selectedSpecie = species.first // Deixa a primeira espécie da lista selecionada por padrão
                if let firstSpecie = species.first{
                    await fetchBreeds(for: firstSpecie.id)
                }
            }
        } catch {
            print("Erro ao buscar espécies: \(error)")
        }
    }
    
    //Faz o get das raças de determinada espécie
    private func fetchBreeds(for specieID: String) async {
        do {
            if let fetchedBreeds = try await service.getBreeds(specie_id: specieID) {
                breeds = fetchedBreeds
                selectedBreed = fetchedBreeds.first // Inicializa com a primeira raça
            }
        } catch {
            print("Erro ao buscar raças: \(error)")
        }
    }
    
    //Nos diz se todos os campos estão vazios
    private func EmptyFields() -> Bool{
        errorMsg = []
        
        if(name.isEmpty || localization.isEmpty || age.isEmpty){
            errorMsg.append("Por favor, preencha todos os campos")
        }
        
        if(!errorMsg.isEmpty){
            showAlert = true
            return true
        }
        showAlert = false
        return false
    }
    
    //Essa anotação @Environment nos permite fazer o equivalente ao `Navigator.pop` do flutter.
    //Entáo, se quisermos fazer o .pop,  basta chamar self.dismiss()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        // O NavigationView basicamente diz ao swift que essa tela ser[a utilizada com uma rota de navegacão,
        // então será possível chamar essa tela em outra.
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Imagem do animal
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 360, height: 200)
                                .clipped()
                                .cornerRadius(8)
                        } else {
                            ZStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 360, height: 200)
                                    .cornerRadius(8)
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.system(size: 40))
                                    Text("Adicionar foto")
                                        .font(.headline)
                                }
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $selectedImage)
                    }
                    
                    // Nome e Sexo
                    HStack {
                        TextField("Nome", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        Picker("Sexo", selection: $sex) {
                            Text("Macho").tag("Macho")
                            Text("Fêmea").tag("Fêmea")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Localização e Idade
                    HStack {
                        TextField("Localização", text: $localization)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        TextField("Idade", text: $age)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    // Animal, Porte e Raça
                    HStack {
                        // Dropdown para Animal
                        Picker("Espécie", selection: $selectedSpecie) {
                            ForEach(species, id: \.self) { specie in
                                Text(specie.name).tag(Optional(specie))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedSpecie) { newValue in
                            if let specie = newValue {
                                Task {
                                    await fetchBreeds(for: specie.id)
                                }
                            }
                        }
                        
                        Picker("Raça", selection: $selectedBreed) {
                            ForEach(breeds, id: \.self) { breed in
                                Text(breed.name).tag(Optional(breed))
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Porte", selection: $size) {
                            ForEach(sizes, id: \.self) { n in
                                Text(n)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                        
                    }
                }
                
                // Descrição
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Botões Publicar e Cancelar
                HStack {
                    Button(action: {
                        showConfirmationAlert = true
                        //Vai mostrar o ALERT de confirmação,
                        // para saber se o usuário realmente deseja publicar
                        
                    }){
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            // Mostra um "loading" circular
                        } else {
                            Text("Publicar")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Cancelar") {
                        self.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    //Cancela a publicação de uma nova listagem, e volta para a tela anterior
                }
            }
            .padding()
        }
        .onAppear {
            //Faz o fetch das espécies
            Task{
                await fetchSpecies()
            }
        }
        .navigationTitle("Nova Listagem")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Erro"),
                message: Text(errorMsg.joined(separator: "\n")),
                dismissButton: .default(Text("OK"))
            )
            //Mostra as mensagens de erro, se tiver;
        }
        .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Confirmar Publicação"),
                        message: Text("Você tem certeza que deseja publicar essa listagem?"),
                        primaryButton: .destructive(Text("Cancelar")) {
                            // Não faz nada, apenas fecha o Alert
                        },
                        secondaryButton: .default(Text("Prosseguir")) {
                            // Chama a função para publicar a listagem
                            Task {
                                try await handlePublish()
                            }
                        }
                    )
                }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}




// Image Picker Wrapper; Serve para escolher a imagem
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // Apenas imagens
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            if let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image as? UIImage
                    }
                }
            }
        }
    }
}
