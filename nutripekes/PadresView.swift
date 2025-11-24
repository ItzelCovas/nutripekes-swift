import SwiftUI

// --- 1. MODELO DE DATOS (Basado en el JSON) ---
// Tiene que ser Codable para leer el JSON de la red.
struct Receta: Codable, Identifiable, Hashable {
    // Usamos 'id' para 'Identifiable', pero lo mapeamos desde "pk"
    let id: String
    let titulo: String
    let ingredientes: [String]
    let imagenURL: String
    let instrucciones: String

    // 'CodingKeys' nos permite "traducir" los nombres del JSON
    // a los nombres que preferimos usar en nuestro código.
    enum CodingKeys: String, CodingKey {
        case id = "pk"
        case titulo = "name"
        case ingredientes = "ingredients"
        case imagenURL = "img_url"
        case instrucciones = "instructions"
    }
}

// --- 2. VIEWMODEL (El que hace el Request) ---
@MainActor // Asegura que los cambios a la UI ocurran en el hilo principal
class RecetarioViewModel: ObservableObject {
    
    @Published var recetas = [Receta]()
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Función 'async' para descargar los datos
    func fetchRecetas() async {
        // Tu URL
        guard let url = URL(string: "https://nutripekes-api.vercel.app/recetas") else {
            errorMessage = "URL inválida"
            return
        }
        
        // Muestra el "cargando..."
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Hacer la petición de red (el "request")
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 2. Decodificar el JSON usando nuestro 'struct Receta'
            let recetasDecodificadas = try JSONDecoder().decode([Receta].self, from: data)
            
            // 3. Actualizar la lista (esto actualiza la UI)
            self.recetas = recetasDecodificadas
            self.isLoading = false
            
        } catch {
            // 4. Manejar cualquier error
            self.isLoading = false
            self.errorMessage = "Error al cargar recetas: \(error.localizedDescription)"
            print("Error al decodificar: \(error)") // Para depuración
        }
    }
}


struct PadresView: View {
    
    // --- 3. USAMOS EL NUEVO VIEWMODEL ---
    @StateObject private var viewModel = RecetarioViewModel()
    
    @EnvironmentObject var speechManager: SpeechManager
    @State private var searchText = ""

    // El filtro ahora usa la lista del ViewModel
    var filteredRecetas: [Receta] {
        if searchText.isEmpty {
            return viewModel.recetas
        } else {
            let lowercasedQuery = searchText.lowercased()
            // Filtra por 'titulo' O por 'ingredientes'
            return viewModel.recetas.filter { receta in
                let tituloCoincide = receta.titulo.lowercased().contains(lowercasedQuery)
                // Lógica para buscar en ingredientes como ["pan", "mantequilla"]
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
                    
                    // --- TÍTULO CON TTS (Sin cambios) ---
                    HStack {
                        Spacer()
                        Text("Padres")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding(.bottom, 5)
                        Spacer()
                        Button(action: {
                            speechManager.speak(text: "Sección de Padres. Aquí encontrarás la tabla de recomendaciones y el recetario.")
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)

                    // --- TABLA CON TTS
                    ZStack(alignment: .topTrailing) {
                        Image("tabla")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                            .padding(.horizontal)
                        
                        Button(action: {
                            let texto = "Tabla de recomendaciones de edad, peso, talla e índice de masa corporal para niños de 3 a 10 años."
                            speechManager.speak(text: texto)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .padding(5)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                        .padding(10)
                    }
                    
                    // --- TÍTULO DE RECETAS CON TTS
                    HStack {
                        Text("Ideas de Lunch")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            speechManager.speak(text: "Ideas de Lunch. Desliza a la izquierda para ver recetas. Toca una para ver los detalles. Puedes buscar por ingrediente.")
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // --- 4. LÓGICA DE CARGA Y SECCIÓN DE RECETAS
                    
                    // Si está cargando, muestra un spinner
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    
                    // Si hubo un error, muéstralo
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.yellow)
                            .padding()
                    
                    // Si la búsqueda no encuentra nada
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
                    
                    // Si todo está bien, muestra las recetas
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
        .onDisappear {
            speechManager.stop()
        }
        // --- 5. LLAMADA A LA API ---
        // .task se ejecuta CADA VEZ que la vista aparece
        .task {
            await viewModel.fetchRecetas()
        }
    }
}

// --- 6. VISTA DE TARJETA AUXILIAR (Actualizada con AsyncImage) ---
struct RecetaCardView: View {
    let imagenURL: String // <-- Ahora recibe una URL
    let titulo: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // AsyncImage carga una imagen desde una URL
            AsyncImage(url: URL(string: imagenURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Llena el espacio
                } else if phase.error != nil {
                    // Si falla la carga, muestra un ícono de error
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                } else {
                    // Mientras carga, muestra un spinner
                    ProgressView()
                }
            }
            .frame(width: 220, height: 130)
            .background(Color.gray.opacity(0.2)) // Fondo para el spinner
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


// --- 7. VISTA DE DETALLE (Actualizada para la API) ---
struct RecetaDetailView: View {
    let receta: Receta
    
    @EnvironmentObject var speechManager: SpeechManager
    
    // Propiedad para separar ingredientes como "pan,mantequilla"
    private var ingredientesLimpios: [String] {
        receta.ingredientes.flatMap { $0.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) } }
    }
    
    // Propiedad para separar las instrucciones que vienen en un solo string
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
                    
                    // Carga la imagen de la URL
                    AsyncImage(url: URL(string: receta.imagenURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            ProgressView() // Spinner si está cargando
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(15)
                    .shadow(radius: 5)

                    // --- Sección de Ingredientes ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Ingredientes")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Spacer()
                            Button(action: {
                                // Lee la lista de ingredientes limpios
                                let texto = ingredientesLimpios.joined(separator: ", ")
                                speechManager.speak(text: "Ingredientes: \(texto)")
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                            }
                        }
                        
                        // Muestra la lista de ingredientes limpios
                        ForEach(ingredientesLimpios, id: \.self) { ingrediente in
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color.white.opacity(0.8))
                                Text(ingrediente.capitalized)
                                    .font(.system(size: 17, design: .rounded))
                            }
                        }
                    }
                    
                    // --- SECCIÓN DE INSTRUCCIONES ---
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Instrucciones")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Spacer()
                            Button(action: {
                                // Lee el texto original completo
                                speechManager.speak(text: "Instrucciones: \(receta.instrucciones)")
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                            }
                        }
                        
                        // Muestra la lista de pasos que separamos
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


// --- VISTAS PREVIAS (Actualizadas) ---
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
        // Usamos uno de los ejemplos de la API para la vista previa
        let previewReceta = Receta(
            id: "01K9XZWJ9RFWPZDWPG2X69VTC7",
            titulo: "Milanesa de Pollo",
            ingredientes: ["pollo"],
            imagenURL: "https://pub-4c1673fbabc74a9dadd292365457c6ac.r2.dev/recipes/82e4c6f2-de2a-4e6e-ac21-4573eeba792a-milanesa.jpg",
            instrucciones: "1 Abrir las pechugas con un cuchillo como si fueran un libro. 2 Batir los huevos con la leche... 3 Colocar las pechugas..."
        )
        
        NavigationView {
            RecetaDetailView(receta: previewReceta)
                .environmentObject(SpeechManager.shared)
        }
    }
}
