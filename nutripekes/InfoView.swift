import SwiftUI

// --- 1. MODELOS DE DATOS PARA DECODIFICAR LA API ---

// El objeto raíz que la API devuelve {"info": [...]}
struct InfoCardResponse: Codable {
    let info: [InfoCard]
}

// Representa un solo par de ["Título", "Descripción"] dentro de 'content'
struct InfoContentItem: Codable, Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    
    // Decodificador personalizado para leer un array de strings ["val1", "val2"]
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.title = try container.decode(String.self)
        self.description = try container.decode(String.self)
    }
}

// Representa una tarjeta de información completa
struct InfoCard: Codable, Identifiable {
    let id: String
    let title: String
    let content: [InfoContentItem]
    let colorCode: String // "R", "G", "Y"
    
    // Mapea los nombres de la API (pk, color) a nuestros nombres (id, colorCode)
    enum CodingKeys: String, CodingKey {
        case id = "pk"
        case title
        case content
        case colorCode = "color"
    }
    
    // Convierte el código de color en un Color de SwiftUI
    var displayColor: Color {
        switch colorCode {
        case "R":
            return Color(red: 200/255, green: 80/255, blue: 70/255) // Rojo oscuro
        case "G":
            return Color(red: 65/255, green: 78/255, blue: 51/255) // Verde oscuro
        case "Y":
            return Color(red: 243/255, green: 182/255, blue: 79/255) // Naranja/amarillo
        default:
            return .gray
        }
    }
}

// --- 2. VIEWMODEL PARA MANEJAR EL REQUEST A LA API ---

@MainActor // Asegura que los cambios a la UI ocurran en el hilo principal
class InfoViewModel: ObservableObject {
    @Published var infoCards = [InfoCard]()
    @Published var isLoading = true // Inicia cargando
    @Published var errorMessage: String? = nil
    
    // Función 'async' que se conecta a la API
    func fetchInfo() async {
        // Tu URL
        guard let url = URL(string: "https://nutripekes-api.vercel.app/info") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }
        
        // Reinicia el estado para una nueva carga
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            // 1. Hace el request
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 2. Decodifica la respuesta JSON
            let decodedResponse = try JSONDecoder().decode(InfoCardResponse.self, from: data)
            
            // 3. Publica los datos en la UI
            self.infoCards = decodedResponse.info
            self.isLoading = false
            
        } catch {
            // 4. Maneja cualquier error
            self.isLoading = false
            self.errorMessage = "Error al cargar la información: \(error.localizedDescription)"
            print(error)
        }
    }
}


// --- 3. VISTA DE LA TARJETA (Actualizada) ---
// Ahora toma un 'InfoCard' y el 'SpeechManager'
struct InfoCardView: View {
    let card: InfoCard
    @EnvironmentObject var speechManager: SpeechManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Título principal de la tarjeta (con TTS)
            HStack {
                Text(card.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    speechManager.speak(text: card.title)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                }
            }
            
            // Itera sobre el 'content'
            ForEach(card.content) { item in
                VStack(alignment: .leading, spacing: 5) {
                    
                    // Subtítulo de contenido (con TTS)
                    HStack {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        Spacer()
                        Button(action: {
                            let textoCompleto = "\(item.title). \(item.description)"
                            speechManager.speak(text: textoCompleto)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.body)
                        }
                    }
                    
                    Text(item.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(card.displayColor) // Usa el color decodificado
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}

// --- 4. VISTA PRINCIPAL (Actualizada) ---
struct InfoView: View {
    
    // Crea el ViewModel
    @StateObject private var viewModel = InfoViewModel()
    
    // Obtiene el motor de voz
    @EnvironmentObject var speechManager: SpeechManager

    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Text("Información")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    // --- LÓGICA DE CARGA ---
                    if viewModel.isLoading {
                        ProgressView() // Muestra "cargando..."
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding(.top, 50)
                    
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage) // Muestra el error
                            .foregroundColor(.yellow)
                    
                    } else {
                        // Muestra las tarjetas descargadas
                        ForEach(viewModel.infoCards) { card in
                            InfoCardView(card: card)
                        }
                    }
                }
                .padding()
                
            }
            .toolbarBackground(
                Color(red: 226/255, green: 114/255, blue: 101/255),
                for: .navigationBar
            )
            
        }
        .onDisappear {
            speechManager.stop()
        }
        // 5. LLAMA A LA API CADA VEZ QUE LA VISTA APARECE
        .task {
            await viewModel.fetchInfo()
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InfoView()
                .environmentObject(SpeechManager.shared) // Inyecta el motor de voz
        }
    }
}
