import SwiftUI

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
    let colorCode: String 
    
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


// 3. VISTA DE LA TARJETA
// 3. VISTA DE LA TARJETA (MODIFICADA CON PLAY/PAUSE)
struct InfoCardView: View {
    let card: InfoCard
    @EnvironmentObject var speechManager: SpeechManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- 1. TÍTULO PRINCIPAL DE LA TARJETA ---
            HStack {
                Text(card.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Spacer()
                
                // Botón Play/Pause para el Título
                Button(action: {
                    // Usamos el ID de la tarjeta (PK de la API)
                    speechManager.speak(text: card.title, id: card.id)
                }) {
                    if speechManager.isSpeaking && speechManager.currentID == card.id {
                        // Icono PAUSA
                        Image(systemName: "pause.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8)) // Un blanco sutil
                    } else {
                        // Icono SPEAKER
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                }
            }
            
            //  CONTENIDO (ITEMS) 
            ForEach(card.content) { item in
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack {
                        Text(item.title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                        // Botón Play/Pause para el Item
                        Button(action: {
                            let textoCompleto = "\(item.title). \(item.description)"
                            speechManager.speak(text: textoCompleto, id: item.id.uuidString)
                        }) {
                            if speechManager.isSpeaking && speechManager.currentID == item.id.uuidString {
                                // Icono PAUSA
                                Image(systemName: "pause.circle.fill")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                            } else {
                                // Icono SPEAKER
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.body)
                            }
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
        .background(card.displayColor)
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
        //LLAMA A LA API CADA QUE LA VISTA APARECE
        .task {
            await viewModel.fetchInfo()
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InfoView()
                .environmentObject(SpeechManager.shared) // motor de voz
        }
    }
}
