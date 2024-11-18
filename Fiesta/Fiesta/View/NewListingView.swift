//
//  NewListingView.swift
//  Fiesta
//
//  Created by PEDRO HENRIQUE VIEIRA DE SOUZA on 16/11/24.
//

import SwiftUI
import PhotosUI

struct NewListingView: View {
    let service = WebService()
    @State private var errorMsg: [String] = []
    @State private var showAlert: Bool = false
    
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool  = false
    @State private var name: String = ""
    @State private var sex: String = "Macho"
    @State private var localization: String = ""
    @State private var age: String = ""
    @State private var animal: String = "Cachorro"
    @State private var size: String = ""
    @State private var breed: String  = ""
    @State private var description: String  = ""
    
    @State private var sizes: [String]  = ["Pequeno","Médio","Grande"]
    //Será usado para armazenar as espécies de animal
    @State private var species: [Specie] = []
    //Será usado para armazenas as raças da espécie desejada
    @State private var breeds: [Breed] = []
    @State private var selectedSpecie: Specie?
    @State private var selectedBreed: Breed?
    
    func imageToData() -> Data? {
        guard let image = selectedImage else { return nil }
        return image.jpegData(compressionQuality: 0.8) // Converte para JPEG com compressão de 80%
    }

    
    func uploadImage(imageData: Data, name: String) async -> Bool {
        // URL da sua API
        let url = URL(string: "http://localhost:1824/f/")!

        // Criar um boundary único
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Configurar a requisição
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Criar o corpo da requisição
        var body = Data()

        // Adicionar os campos de texto
        body.append(contentsOf: "--\(boundary)\r\n".data(using: .utf8)!)
        body.append(contentsOf: "Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append(contentsOf: name.data(using: .utf8)!)
        body.append(contentsOf: "\r\n".data(using: .utf8)!)
        
        // Adicionar a imagem
        body.append(contentsOf: "--\(boundary)\r\n".data(using: .utf8)!)
        body.append(contentsOf: "Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append(contentsOf: "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(contentsOf: imageData) // Aqui estamos adicionando a imagem como dados binários
        body.append(contentsOf: "\r\n".data(using: .utf8)!)
        
        // Finalizar o corpo
        body.append(contentsOf: "--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Atribuir o corpo da requisição
        request.httpBody = body
        
        // Enviar a requisição
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            print(response.description)
            // Verificar a resposta
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Sucesso
                return true
            } else {
                // Erro
                return false
            }
        } catch {
            print("Erro ao enviar imagem: \(error)")
            return false
        }
    }
    
    
    
    
    
    private func fetchSpecies() async {
        do {
            if let fetchedSpecies = try await service.getSpecies() {
                species = fetchedSpecies
                selectedSpecie = species.first
            }
        } catch {
            print("Erro ao buscar espécies: \(error)")
        }
    }
    
    private func fetchBreeds(for specieID: String) async {
        do {
            if let fetchedBreeds = try await service.getBreeds(specie_id: specieID) {
                breeds = fetchedBreeds
            }
            selectedBreed = nil
        } catch {
            print("Erro ao buscar raças: \(error)")
        }
    }
    
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
                        Picker("Animal", selection: $selectedSpecie) {
                            ForEach(species, id: \.self) { specie in
                                Text(specie.name)
                                    .font(.footnote)
                                    .truncationMode(.tail)
                                //                                    .lineLimit(1)
                                    .tag(specie as Specie?)
                                
                                
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle()) // Exibe como um menu dropdown
                        .onChange(of: selectedSpecie ?? Specie(id: "OI", name: "oi")) { newValue in
                            // Atualiza as raças ao selecionar uma nova espécie
                            selectedSpecie = newValue
                            Task{
                                await fetchBreeds(for: newValue.id)
                                
                            }
                        }
                        
                        /*.onChange(of: selectedBreed ?? Breed(id: "OI", specie_id: "oi", name: "oi")) { newValue in
                         // Atualiza as raças ao selecionar uma nova espécie
                         Task{
                         if let data = try await service.getBreeds(specie_id: newValue.id){
                         self.breeds = data
                         self.selectedBreed = Breed(id: "", specie_id: "", name: "")
                         }
                         }
                         }*/
                        
                        
                        
                        
                        Picker("Raça", selection: $selectedBreed){
                            ForEach(breeds) { breed in
                                Text(breed.name)
                                    .tag(breed as Breed?)
                                    .lineLimit(1)
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
                        .onChange(of: size){ newValue in
                            Task{
                                size = newValue
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .pickerStyle(MenuPickerStyle())
                        
                        
                        
                    }
                    
                    
                    /*TextField("Raça", text: $breed)
                     .padding()
                     .background(Color.gray.opacity(0.2))
                     .cornerRadius(8)*/
                }
                
                // Descrição
                TextEditor(text: $description)
                    .frame(height: 100)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                // Botões Publicar e Cancelar
                HStack {
                    Button("Publicar") {
                        
                        // Não deixa publicar se os campos estiverem vazios
                        if(EmptyFields()){
                            return
                        }
                        
                        // Verificar se a imagem está selecionada
                        if let imageData = imageToData() {
                            Task {
                                let success = await uploadImage(imageData: imageData, name: name)
                                if success {
                                    print("Imagem enviada com sucesso")
                                } else {
                                    print("Falha ao enviar a imagem")
                                }
                            }
                        } else {
                            print("Nenhuma imagem selecionada")
                        }
                        
                        
                        print("\(localization) \(name) \(sex) \(age)  \(size)")
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
                }
            }
            .padding()
        }
        .onAppear {
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
                }
    }
}




// Image Picker Wrapper
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
