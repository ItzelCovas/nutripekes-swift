import SwiftUI

struct JuegoView: View {
    
    @StateObject private var viewModel = JuegoViewModel()
    
    // Estados para los popups
    @Environment(\.dismiss) var dismiss
    @State private var showExitAlert = false
    
    // Estados del timer 
    @Environment(\.scenePhase) var scenePhase
    @State private var timeUsageAlert = false
    @State private var usageTimer: Timer?
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("fondo_juego")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                ForEach(viewModel.foodItems) { food in
                    Image(food.imageName)
                        .resizable()
                        .frame(width: viewModel.foodSize.width, height: viewModel.foodSize.height)
                        .position(food.position)
                }
                
                //  CAPA 3: Jugador 
                if let character = viewModel.selectedCharacter {
                    Image(character.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: viewModel.playerSize.width, height: viewModel.playerSize.height)
                        .position(viewModel.playerPosition)
                }
                

                if viewModel.gameState == .jugando || viewModel.gameState == .gameOver {
                    VStack { // Contenedor principal de la UI
                        HStack(alignment: .top) { // Barra superior
                            
                            // --- Grupo Izquierdo (Vidas y Puntos) ---
                            VStack(alignment: .leading, spacing: 10) {
                                // Vidas (Arriba)
                                HStack(spacing: 5) {
                                    ForEach(0..<3, id: \.self) { index in
                                        Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                                            .font(.title)
                                            .foregroundColor(.red)
                                    }
                                }
                                
                                // Puntos (Abajo)
                                Text("Puntos: \(viewModel.score)")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black.opacity(0.5))
                                    .cornerRadius(15)
                            }
                            
                            Spacer() // Empuja los grupos a los lados
                            
                            //  Grupo Derecho (Botón de Salir)
                            if viewModel.gameState == .jugando {
                                Button(action: {
                                    viewModel.pauseGame() // Pausa el motor del juego
                                    stopUsageTimer()      // Pausa el timer de 15 min
                                    showExitAlert = true  // Muestra el popup de confirmación
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.red.opacity(0.8))
                                        .shadow(radius: 3)
                                }
                                .padding(.top, 5) // Ajuste vertical
                            }
                        }
                        .padding(.leading, 20) // Mantiene el margen izquierdo de 20
                        .padding(.trailing, 50) // Aumenta el margen derecho a 30 (mueve el botón X 10 puntos a la izquierda)
                        
                        Spacer() // Empuja la barra superior hacia arriba
                    }
                    .padding(.top, 50) // Margen para el notch/isla
                }
                
                
                // --- CAPA 5: Overlays (Selección, Instrucciones, etc.) ---
                JuegoOverlay(viewModel: viewModel)
                
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if viewModel.gameState == .jugando {
                            viewModel.movePlayer(to: value.location.x)
                        }
                    }
            )
            // (Modificadores de alerta y timers)
            .alert("¿Salir del Juego?", isPresented: $showExitAlert) {
                Button("Salir", role: .destructive) {
                    dismiss()
                }
                Button("Continuar Jugando", role: .cancel) {
                    viewModel.resumeGame()
                    startUsageTimer()
                }
            } message: {
                Text("¿Estás seguro de que quieres salir? Tu puntuación actual se perderá.")
            }
            .alert("¡Buen juego!", isPresented: $timeUsageAlert) {
                Button("OK", role: .cancel) {
                    viewModel.resumeGame()
                    startUsageTimer()
                }
            } message: {
                Text("Has estado jugando por 5 minutos. ¡Es un buen momento para tomar un descanso!")
            }
            .onAppear {
                viewModel.setScreenSize(geo.size)
                startUsageTimer()
            }
            .onDisappear {
                stopUsageTimer()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    if viewModel.gameState == .jugando {
                        viewModel.resumeGame()
                        startUsageTimer()
                    }
                } else if newPhase == .inactive || newPhase == .background {
                    viewModel.pauseGame()
                    stopUsageTimer()
                }
            }
            .onChange(of: viewModel.gameState) { newGameState in
                if newGameState == .jugando {
                    startUsageTimer()
                } else {
                    stopUsageTimer()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // --- Funciones del Timer de 5 min (sin cambios) ---
    
    private func startUsageTimer() {
        guard viewModel.gameState == .jugando else { return }
        guard usageTimer == nil else { return }
        
        let timeInterval: TimeInterval = 300 // 5 minutos
        
        usageTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            viewModel.pauseGame()
            self.timeUsageAlert = true
        }
        print("Timer del Juego iniciado (15 min).")
    }

    private func stopUsageTimer() {
        usageTimer?.invalidate()
        usageTimer = nil
        print("Timer del Juego detenido.")
    }
}

// --- Vista Auxiliar para los Menús ---
struct JuegoOverlay: View {
    
    @ObservedObject var viewModel: JuegoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if viewModel.gameState != .jugando {
            
            ZStack {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    switch viewModel.gameState {
                    case .seleccionPersonaje:
                        SeleccionPersonajeView(viewModel: viewModel)
                    case .instrucciones:
                        InstruccionesView(viewModel: viewModel)
                    case .countdown:
                        Text(viewModel.countdownText)
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                    case .gameOver:
                        GameOverView(viewModel: viewModel)
                    case .jugando:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 25)
                .foregroundColor(.white)
                
                // Botón de Salir (X) en overlays 
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.red.opacity(0.9))
                                .shadow(radius: 3)
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }
        }
    }
}

// --- Vistas para cada estado del Overlay

struct SeleccionPersonajeView: View {
    @ObservedObject var viewModel: JuegoViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("¡Elige tu personaje!")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.trailing, 20)

            HStack(spacing: -40) {
                
                ForEach(viewModel.personajes) { personaje in
                    Button(action: {
                        viewModel.selectCharacter(personaje)
                    }) {
                        VStack {
                            Image(personaje.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .background(Color.white.opacity(0.3))
                                .clipShape(Circle())
                                .padding(24)
                                .padding(.horizontal, -1)
                            
                            Text(personaje.name)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .padding(.vertical)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

            }
        }
    }
}

struct InstruccionesView: View {
    @ObservedObject var viewModel: JuegoViewModel
    
    var body: some View {
        Text("¡Atrápalo!")
            .font(.system(size: 50, weight: .bold, design: .rounded))
        
        Text("Mueve a \(viewModel.selectedCharacter?.name ?? "tu personaje") con tu dedo para atrapar la comida saludable. ¡Evita la comida chatarra o perderás vidas!")
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .multilineTextAlignment(.center)
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)

        Button("¡OK!") {
            viewModel.startCountdown()
        }
        .font(.system(size: 24, weight: .bold, design: .rounded))
        .padding(.horizontal, 40)
        .padding(.vertical, 15)
        .background(Color.yellow)
        .foregroundColor(.black)
        .cornerRadius(20)
    }
}


struct GameOverView: View {
    @ObservedObject var viewModel: JuegoViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¡Juego Terminado!")
                .font(.system(size: 35, weight: .bold, design: .rounded))
            
            Text("Tu Puntuación: \(viewModel.score)")
                .font(.system(size: 30, weight: .medium, design: .rounded))

            Button("Jugar de Nuevo") {
                viewModel.resetGame()
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.yellow)
            .foregroundColor(.black)
            .cornerRadius(20)
            
            Button("Salir del Juego") {
                dismiss()
            }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .padding(.top, 10)
        }
    }
}

// --- Vista Previa ---
struct JuegoView_Previews: PreviewProvider {
    static var previews: some View {
        JuegoView()
    }
}
