import SwiftUI

struct JuegoView: View {
    
    @StateObject private var viewModel = JuegoViewModel()
    
    @Environment(\.dismiss) var dismiss
    @State private var showExitAlert = false
    
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
                            
                            // Grupo Izquierdo (Vidas y Puntos)
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
                            
                            Spacer()
                            
                            //  Grupo Derecho (Botón de Salir)
                            if viewModel.gameState == .jugando {
                                Button(action: {
                                    viewModel.pauseGame()
                                    stopUsageTimer()
                                    showExitAlert = true
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.red)
                                        .background(Circle().fill(Color.white))
                                        .shadow(radius: 3)
                                }
                                .padding(.top, 5)
                            }
                        }
                        .padding(.leading, 20)
                        .padding(.trailing, 50)
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                }
                                
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
                    viewModel.stopMusicCompletely() // Aseguramos que pare al salir
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
                Text("Has estado jugando por 10 minutos. ¡Es un buen momento para tomar un descanso!")
            }
            .onAppear {
                viewModel.setScreenSize(geo.size)
                startUsageTimer()
            }
            .onDisappear {
                stopUsageTimer()
                viewModel.stopMusicCompletely() // IMPORTANTE: Parar música al irse de la vista
            }
            .onChange(of: scenePhase) {_, newPhase in
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
            .onChange(of: viewModel.gameState) { _,newGameState in
                if newGameState == .jugando {
                    startUsageTimer()
                } else {
                    stopUsageTimer()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    //  Funciones del Timer
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

struct JuegoOverlay: View {
    
    @ObservedObject var viewModel: JuegoViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if viewModel.gameState != .jugando {
            
            ZStack {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                // Contenido Central (Menú)
                VStack {
                    switch viewModel.gameState {
                    case .seleccionPersonaje:
                        SeleccionPersonajeView(viewModel: viewModel)
                    case .instrucciones:
                        InstruccionesView(viewModel: viewModel)
                    case .countdown:
                        Text(viewModel.countdownText)
                            //.border(Color.yellow, width: 3)
                            .padding(.leading, -35)
                            .font(.system(size: 100, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    case .gameOver:
                        GameOverView(viewModel: viewModel)
                    case .jugando:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                //Botón de Salir (X)
                VStack {
                    HStack {
                        Button(action: {
                            viewModel.stopMusicCompletely()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.red)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 3)
                        }
                        
                        Spacer()
                    }
                    Spacer()
                }
                //.border(.yellow)
                .padding(.top, 50)
                .padding(.leading, 20)
                .padding(.trailing, 60)
            }
        }
    }
}

 
struct SeleccionPersonajeView: View {
    @ObservedObject var viewModel: JuegoViewModel
    
    var body: some View {
        VStack(spacing: 50) {
            Text("¡Elige tu personaje!")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                //.border(Color.white, width: 2)
                .padding(.leading,-10)
            
                
            HStack(spacing: 30) {
                ForEach(viewModel.personajes) { personaje in
                    Button(action: {
                        viewModel.selectCharacter(personaje)
                    }) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 120, height: 120)
                                
                                Image(personaje.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 90)
                            }
                            Text(personaje.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .padding(.leading, -30)
    }
}

struct InstruccionesView: View {
    @ObservedObject var viewModel: JuegoViewModel
    var body: some View {
        // CONTENIDO
        VStack(spacing: 40) {
            Text("¡Atrápalo!")
                //.border(Color.white, width: 2)
                .padding(.leading, -20)
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Mueve a \(viewModel.selectedCharacter?.name ?? "tu personaje") con tu dedo para atrapar la comida saludable.\n\n¡Evita la comida chatarra o perderás vidas!")
                //.border(Color.red)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                
            Button("¡OK!") {
                viewModel.startCountdown()
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .padding(.horizontal, 40)
            .padding(.vertical, 15)
            .background(Color.yellow)
            .padding(.leading, -10)
            .foregroundColor(.black)
            .cornerRadius(20)
        }
        //.border(Color.yellow)
        .padding(.leading, -5)
        .padding(.trailing, 30)
    }
}



struct GameOverView: View {
    @ObservedObject var viewModel: JuegoViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Juego Terminado")
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
                viewModel.stopMusicCompletely()
                dismiss()
            }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white.opacity(0.7))
            .padding(.top, 10)
        }
    }
}

struct JuegoView_Previews: PreviewProvider {
    static var previews: some View {
        JuegoView()
    }
}
