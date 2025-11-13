import SwiftUI

struct MainView: View {
    @State private var isMenuOpen = false // menú empieza cerrado
    let childAge: Int //1. Aceptar la edad

    var body: some View {
        ZStack(alignment: .leading) {
            // 2. Pasar la edad a DashboardView
            DashboardView(isMenuOpen: $isMenuOpen, childAge: childAge)

            // Sombreado semitransparente que aparece con el menú
            if isMenuOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { isMenuOpen = false } // Tocar afuera cierra el menú
            }
            
            // El menú que se desliza
            MenuView(isMenuOpen: $isMenuOpen) // Le pasamos el binding para que pueda cerrarse
                .frame(width: 270)
                .offset(x: isMenuOpen ? 0 : -270)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: isMenuOpen)
        .navigationBarHidden(true) // Ocultamos la barra de navegación por defecto de NavigationView
    }
}

// Sub-vista para el Menú Lateral
struct MenuView: View {
    @Binding var isMenuOpen: Bool
    
    // 1. Obtenemos el motor de voz del entorno
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- SECCIÓN JUEGO CON TTS ---
            HStack {
                Text("Juego")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    speechManager.speak(text: "Juego. ¡Atrápalo!")
                }) {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
            }
            .foregroundColor(.white)
            .padding(.top, 80)
            .padding(.bottom, 0)

            NavigationLink(destination: JuegoView()) {
                HStack {
                    Text("¡Atrápalo!")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            // --- SECCIÓN PADRES CON TTS ---
            HStack {
                Text("Padres")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    speechManager.speak(text: "Padres. Tabla y Recetario.")
                }) {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
            }
            .foregroundColor(.white)
            .padding(.top, 5)
            .padding(.bottom, 10)

            NavigationLink(destination: PadresView()) {
                HStack {
                    Text("Tabla y Recetario")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            // --- SECCIÓN INFORMACIÓN CON TTS ---
            HStack {
                Text("Información")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    speechManager.speak(text: "Información. Información General. Guía de Uso.")
                }) {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
            }
            .foregroundColor(.white)
            .padding(.top, 10)
            .padding(.bottom, 10)

            NavigationLink(destination: InfoView()) {
                HStack {
                    Text("Información General")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            NavigationLink(destination: GuiaUsoView()) {
                HStack {
                    Text("Guía de Uso")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            // --- SECCIÓN AJUSTES CON TTS ---
            HStack {
                Text("Ajustes")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Spacer()
                Button(action: {
                    speechManager.speak(text: "Ajustes. Cambiar Edad.")
                }) {
                    Image(systemName: "speaker.wave.2.fill").font(.title2)
                }
            }
            .foregroundColor(.white)
            .padding(.top, 20)
            .padding(.bottom, 10)

            NavigationLink(destination: ConfiguracionView()) {
                HStack {
                    Text("Cambiar Edad")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(20)
        .font(.system(size: 20, weight: .bold, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 65/255, green: 78/255, blue: 51/255).opacity(0.95))
        .edgesIgnoringSafeArea(.all)
        .onDisappear {
            isMenuOpen = false // Asegura que el menú se cierre al navegar
            speechManager.stop() // ¡Detiene la voz si el menú se cierra!
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(childAge:5)
            // 2. ¡Importante! Añade esto para que el Preview no crashee
            .environmentObject(SpeechManager.shared)
    }
}
