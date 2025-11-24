import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @Binding var isMenuOpen: Bool
    
    // --- 1. ESTADOS PARA TTS Y TIMERS ---
    @EnvironmentObject var speechManager: SpeechManager
    @Environment(\.scenePhase) var scenePhase
    @State private var timeUsageAlert = false
    @State private var usageTimer: Timer?
    @State private var showingGuiaSheet = false

    // --- 2. OBSERVAR LA EDAD GUARDADA ---
    @AppStorage("childAge") var storedAge: Int = 0
    
    init(isMenuOpen: Binding<Bool>, childAge: Int) {
        _isMenuOpen = isMenuOpen
        _viewModel = StateObject(wrappedValue: DashboardViewModel(age: childAge))
    }
    
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()

            VStack {
                topNavBar
                Spacer()
                appleImage
                Spacer()
                countersSection
                Spacer()
            }
        }
        .sheet(isPresented: $showingGuiaSheet) {
            NavigationView {
                GuiaUsoView() // Asumo que tienes esta vista definida en otro lado
                    .navigationBarItems(trailing: Button("Cerrar") {
                        showingGuiaSheet = false
                    })
            }
            .environmentObject(speechManager)
        }
        
        // --- Modificadores de Alerta y Timer ---
        .alert("¡Hora de un descanso!", isPresented: $timeUsageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Has pasado 15 minutos en el dashboard. ¡Es bueno tomar un pequeño descanso!")
        }
        .onAppear {
            startUsageTimer()
            // Si la edad cambió en segundo plano
            if storedAge != (viewModel.foodGroups.first?.targetPoints ?? 0) {
                 viewModel.reloadData(for: storedAge, forceReset: true)
            }
        }
        .onDisappear {
            stopUsageTimer()
            speechManager.stop()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                startUsageTimer()
            } else if newPhase == .inactive || newPhase == .background {
                stopUsageTimer()
                speechManager.stop()
            }
        }
        // Este modificador "escucha" cualquier cambio en 'storedAge'.
        .onChange(of: storedAge) { _, newAge in
            viewModel.reloadData(for: newAge, forceReset: true)
        }
    }
    
    // --- 5. FUNCIONES DEL TEMPORIZADOR ---
    
    private func startUsageTimer() {
        stopUsageTimer()
        let timeInterval: TimeInterval = 300 // 5 min para pruebas, ajusta a 900
        usageTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            self.timeUsageAlert = true
        }
        print("Timer del Dashboard iniciado.")
    }

    private func stopUsageTimer() {
        usageTimer?.invalidate()
        usageTimer = nil
        print("Timer del Dashboard detenido.")
    }
    
    
    // --- 6. SUBVISTAS ---
    
    private var topNavBar: some View {
        HStack {
            Button(action: { isMenuOpen.toggle() }) {
                Image(systemName: "line.horizontal.3").font(.title)
            }
            Spacer()
            Image("titulo").resizable().scaledToFit().frame(width: 120)
            Spacer()
            
            Button(action: {
                let texto = "Esta es la pantalla principal. Toca un círculo para registrar las porciones de comida que has comido hoy. ¡Mira cómo la manzanita se pone feliz!"
                speechManager.speak(text: texto)
            }) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.title2)
            }
            
            Button(action: {
                showingGuiaSheet = true
            }) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title)
            }
            .padding(.leading, 5)
        }
        .foregroundColor(.white).padding()
    }
    
    private var appleImage: some View {
        Image(viewModel.appleImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 280)
    }
    
    private var countersSection: some View {
        VStack {
            HStack(alignment: .top, spacing: 15) {
                ForEach(viewModel.foodGroups.prefix(4)) { group in
                    Button(action: {
                        self.viewModel.selectedGroup = group
                        self.viewModel.showingConfirmation = true
                    }) {
                        let consumed = Double(group.targetPoints - group.remainingPoints)
                        let total = Double(group.targetPoints)
                        let progress = (total == 0) ? 0 : (consumed / total)

                        // Asumo que tienes CounterCircleView en otro archivo o más abajo
                        CounterCircleView(
                            labelText: group.name,
                            borderColor: group.color,
                            count: group.remainingPoints,
                            progress: progress
                        )
                    }
                }
            }
            
            if let waterGroup = viewModel.foodGroups.last {
                Button(action: {
                    self.viewModel.selectedGroup = waterGroup
                    self.viewModel.showingConfirmation = true
                }) {
                    let consumed = Double(waterGroup.targetPoints - waterGroup.remainingPoints)
                    let total = Double(waterGroup.targetPoints)
                    let progress = (total == 0) ? 0 : (consumed / total)

                    CounterCircleView(
                        labelText: waterGroup.name,
                        borderColor: waterGroup.color,
                        count: waterGroup.remainingPoints,
                        progress: progress
                    )
                }.padding(.top, 10)
            }
        }
        // MODIFICACIÓN PRINCIPAL: Usamos .sheet en lugar de .confirmationDialog
        .sheet(isPresented: $viewModel.showingConfirmation) {
            if let group = viewModel.selectedGroup {
                // Llamamos a la nueva vista de control de porciones
                ControlPorcionesSheet(
                    viewModel: viewModel,
                    group: group,
                    isPresented: $viewModel.showingConfirmation
                )
                .environmentObject(speechManager)
                // Permitimos que la hoja de ejemplos se abra desde la hoja de control
                .sheet(isPresented: $viewModel.showingExamplesSheet) {
                    ExampleSheetView(group: group)
                        .environmentObject(speechManager)
                }
            }
        }
    }
}

// --- VISTA NUEVA: HOJA DE CONTROL DE PORCIONES (+ / -) ---
struct ControlPorcionesSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    var group: FoodGroup
    @Binding var isPresented: Bool
    
    @EnvironmentObject var speechManager: SpeechManager

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // Título e Icono representativo
                VStack(spacing: 10) {
                    Text(group.examples.first?.emoji ?? "🍎")
                        .font(.system(size: 80))
                    
                    Text(group.name.replacingOccurrences(of: "\n", with: " "))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(group.color)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // --- SECCIÓN DE CONTROLES ---
                HStack(spacing: 40) {
                    
                    // BOTÓN MENOS (-)
                    Button(action: {
                        viewModel.addPortion(for: group.id)
                        speechManager.speak(text: "Corrección")
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            // Se pone gris si no hemos comido nada (restantes == meta)
                            .foregroundColor(group.remainingPoints >= group.targetPoints ? .gray.opacity(0.3) : .red)
                    }
                    .disabled(group.remainingPoints >= group.targetPoints)
                    
                    // CONTADOR CENTRAL (Muestra lo que llevas comido)
                    VStack {
                        let consumidas = group.targetPoints - group.remainingPoints
                        Text("\(consumidas)")
                            .font(.system(size: 70, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText()) // Animación suave (iOS 16+)
                        
                        Text("de \(group.targetPoints)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    // BOTÓN MÁS (+)
                    Button(action: {
                        viewModel.consumePoint(for: group.id)
                        
                        // Feedback de audio
                       
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            // Se pone gris si ya comimos todo (restantes == 0)
                            .foregroundColor(group.remainingPoints <= 0 ? .gray.opacity(0.3) : .green)
                    }
                    .disabled(group.remainingPoints <= 0)
                }
                
                Spacer()
                
                // Botón para ver ejemplos
                Button(action: {
                    viewModel.showingExamplesSheet = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("Ver ejemplos de alimentos")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(group.color.opacity(0.1))
                    .foregroundColor(group.color)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            .navigationBarItems(trailing: Button("Listo") {
                isPresented = false
            })
        }
    }
}

// --- VISTA DE EJEMPLOS (Existente) ---
struct ExampleSheetView: View {
    let group: FoodGroup
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var speechManager: SpeechManager

    var body: some View {
        NavigationView {
            List(group.examples) { example in
                HStack(spacing: 20) {
                   
                    Text(example.emoji)
                        .font(.system(size: 40))
                        .frame(width: 40)
                   
                    Text(example.name)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                   
                    Spacer()
                   
                    Button(action: {
                        speechManager.speak(text: example.name)
                    }) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 8)
            }
            .listStyle(.plain)
            .navigationTitle("Ejemplos de \(group.name.replacingOccurrences(of: "\n", with: " "))")
            .navigationBarItems(trailing: Button("Cerrar") {
                dismiss()
            })
        }
        .onDisappear {
            speechManager.stop()
        }
    }
}
