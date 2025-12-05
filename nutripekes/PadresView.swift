import SwiftUI

// MODELO DE DATOS (JSON)
struct Receta: Codable, Identifiable, Hashable {
    let id: String
    let titulo: String
    let ingredientes: [String]
    let imagenURL: String
    let instrucciones: String

    enum CodingKeys: String, CodingKey {
        case id = "pk"
        case titulo = "name"
        case ingredientes = "ingredients"
        case imagenURL = "img_url"
        case instrucciones = "instructions"
    }
}

// VIEWMODEL
@MainActor
class RecetarioViewModel: ObservableObject {
    
    @Published var recetas = [Receta]()
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    func fetchRecetas() async {
        guard recetas.isEmpty else { return }
        guard let url = URL(string: "https://nutripekes-api.vercel.app/recetas") else {
            errorMessage = "URL inválida"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let recetasDecodificadas = try JSONDecoder().decode([Receta].self, from: data)
            self.recetas = recetasDecodificadas
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = "Error al cargar recetas: \(error.localizedDescription)"
            print("Error al decodificar: \(error)")
        }
    }
}


struct PadresView: View {
    
    @StateObject private var viewModel = RecetarioViewModel()
    
    @EnvironmentObject var speechManager: SpeechManager
    @State private var searchText = ""

    var filteredRecetas: [Receta] {
        if searchText.isEmpty {
            return viewModel.recetas
        } else {
            let lowercasedQuery = searchText.lowercased()
            return viewModel.recetas.filter { receta in
                let tituloCoincide = receta.titulo.lowercased().contains(lowercasedQuery)
                let ingredienteCoincide = receta.ingredientes.contains { ingrediente in
                    ingrediente.lowercased().contains(lowercasedQuery)
                }
                return tituloCoincide || ingredienteCoincide
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    // --- TÍTULO PRINCIPAL ---
                    HStack {
                        Spacer()
                        Text("Padres")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.bottom, 5)
                        Spacer()
                        
                        // Botón Intro Padres
                        Button(action: {
                            speechManager.speak(text: "Sección de Padres. Aquí encontrarás la tabla de recomendaciones y el recetario.", id: "padres_intro")
                        }) {
                            if speechManager.isSpeaking && speechManager.currentID == "padres_intro" {
                                Image(systemName: "pause.circle.fill").font(.title2).foregroundColor(.white)
                            } else {
                                Image(systemName: "speaker.wave.2.fill").font(.title2).foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // --- TABLA CON TTS ---
                    ZStack(alignment: .topTrailing) {
                        Image("tabla")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        
                        // Botón Tabla
                        Button(action: {
                            let texto = "Tabla de recomendaciones de edad, peso, talla e índice de masa corporal para niños de 3 a 10 años."
                            speechManager.speak(text: texto, id: "padres_tabla")
                        }) {
                            if speechManager.isSpeaking && speechManager.currentID == "padres_tabla" {
                                Image(systemName: "pause.circle.fill")
                                    .font(.title2)
                                    .padding(5)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .padding(5)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(10)
                    }
                    
                    // --- TÍTULO DE RECETAS CON TTS ---
                    HStack {
                        Text("Ideas de Lunch")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Botón Intro Recetas
                        Button(action: {
                            speechManager.speak(text: "Ideas de Lunch. Desliza a la izquierda para ver recetas. Toca una para ver los detalles. Puedes buscar por ingrediente.", id: "padres_recetas_intro")
                        }) {
                            if speechManager.isSpeaking && speechManager.currentID == "padres_recetas_intro" {
                                Image(systemName: "pause.circle.fill").font(.title2).foregroundColor(.white)
                            } else {
                                Image(systemName: "speaker.wave.2.fill").font(.title2).foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    
                    // SPINNER DE CARGA
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    
                    // MENSAJE DE ERROR
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.yellow)
                            .padding()
                    
                    // MENSAJE DE BÚSQUEDA VACÍA
                    } else if filteredRecetas.isEmpty {
                        HStack {
                            Spacer()
                            Text(searchText.isEmpty ? "No hay recetas disponibles." : "No se encontraron recetas con ese ingrediente.")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                        .padding(.horizontal)
                    
                    // LISTA DE RECETAS
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(filteredRecetas) { receta in
                                    NavigationLink(destination: RecetaDetailView(receta: receta)) {
                                        RecetaCardView(
                                            imagenURL: receta.imagenURL,
                                            titulo: receta.titulo
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                        }
                    }
                }
                .padding(.vertical)
            }
            .searchable(text: $searchText, prompt: "Buscar por ingrediente...")
        }
        .toolbarBackground(
            Color(red: 226/255, green: 114/255, blue: 101/255),
            for: .navigationBar
        )
        //.onDisappear {
          //  speechManager.stop()
        //}
        .task {
            await viewModel.fetchRecetas()
        }
    }
}

// VISTA DE TARJETA AUXILIAR
struct RecetaCardView: View {
    let imagenURL: String
    let titulo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            AsyncImage(url: URL(string: imagenURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 220, height: 130)
            .background(Color.gray.opacity(0.2))
            .clipped()

            Text(titulo)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding()
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .frame(width: 220)
    }
}


struct RecetaDetailView: View {
    let receta: Receta
    
    @EnvironmentObject var speechManager: SpeechManager
    
    private var ingredientesLimpios: [String] {
        receta.ingredientes.flatMap { $0.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) } }
    }
    
    private var pasosInstrucciones: [String] {
        receta.instrucciones.components(separatedBy: .decimalDigits)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "."))) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Imagen Principal
                    AsyncImage(url: URL(string: receta.imagenURL)) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(contentMode: .fill)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    // --- SECCIÓN INGREDIENTES ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Ingredientes")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Spacer()
                            
                            // Botón Ingredientes
                            Button(action: {
                                let texto = ingredientesLimpios.joined(separator: ", ")
                                // Usamos el ID de la receta + "_ing" para hacerlo único
                                speechManager.speak(text: "Ingredientes: \(texto)", id: "\(receta.id)_ing")
                            }) {
                                if speechManager.isSpeaking && speechManager.currentID == "\(receta.id)_ing" {
                                    Image(systemName: "pause.circle.fill").font(.title2)
                                } else {
                                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                                }
                            }
                        }
                        
                        ForEach(ingredientesLimpios, id: \.self) { ingrediente in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text(ingrediente.capitalized)
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                    }
                    
                    // --- SECCIÓN INSTRUCCIONES ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Instrucciones")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Spacer()
                            
                            // Botón Instrucciones
                            Button(action: {
                                // Usamos el ID de la receta + "_ins"
                                speechManager.speak(text: "Instrucciones: \(receta.instrucciones)", id: "\(receta.id)_ins")
                            }) {
                                if speechManager.isSpeaking && speechManager.currentID == "\(receta.id)_ins" {
                                    Image(systemName: "pause.circle.fill").font(.title2)
                                } else {
                                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                                }
                            }
                        }
                        
                        ForEach(Array(pasosInstrucciones.enumerated()), id: \.offset) { index, instruccion in
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .frame(width: 30)
                                Text(instruccion)
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .foregroundColor(.white)
            }
        }
        .navigationTitle(receta.titulo)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            speechManager.stop()
        }
    }
}


struct PadresView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PadresView()
                .environmentObject(SpeechManager.shared)
        }
    }
}

struct RecetaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let previewReceta = Receta(
            id: "01K9XZWJ9RFWPZDWPG2X69VTC7",
            titulo: "Milanesa de Pollo",
            ingredientes: ["pollo"],
            imagenURL: "https://pub-4c1673fbabc74a9dadd292365457c6ac.r2.dev/recipes/82e4c6f2-de2a-4e6e-ac21-4573eeba792a-milanesa.jpg",
            instrucciones: "1 Abrir las pechugas... 2 Batir huevos..."
        )
        
        NavigationView {
            RecetaDetailView(receta: previewReceta)
                .environmentObject(SpeechManager.shared)
        }
    }
}
