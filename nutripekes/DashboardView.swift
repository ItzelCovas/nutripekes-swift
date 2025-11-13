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
                GuiaUsoView()
                    .navigationBarItems(trailing: Button("Cerrar") {
                        showingGuiaSheet = false
                    })
            }
            .environmentObject(speechManager)
        }
        
        // --- Modificadores de Alerta y Timer (Sin cambios) ---
        .alert("¡Hora de un descanso!", isPresented: $timeUsageAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Has pasado 15 minutos en el dashboard. ¡Es bueno tomar un pequeño descanso!")
        }
        .onAppear {
            startUsageTimer()
            
            // --- 3. VERIFICACIÓN EXTRA ---
            // Si la edad en memoria es diferente a la edad con la que
            // se cargó el ViewModel, forzamos la recarga CON reseteo.
            // (Esto es por si el usuario cambió la edad con la app cerrada)
            if storedAge != (viewModel.foodGroups.first?.targetPoints ?? 0) { // Compara con algo que dependa de la edad
                 viewModel.reloadData(for: storedAge, forceReset: true)
            }
        }
        .onDisappear {
            stopUsageTimer()
            speechManager.stop()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                startUsageTimer()
            } else if newPhase == .inactive || newPhase == .background {
                stopUsageTimer()
                speechManager.stop()
            }
        }
        

        // Este modificador "escucha" cualquier cambio en 'storedAge'.
        .onChange(of: storedAge) { newAge in
            // Llama a la función de recarga y le pasa 'forceReset: true'
            // para borrar el progreso.
            viewModel.reloadData(for: newAge, forceReset: true)
        }
    }
    
    // --- 5. FUNCIONES DEL TEMPORIZADOR (Sin cambios) ---
    
    private func startUsageTimer() {
        stopUsageTimer()
        let timeInterval: TimeInterval = 900 // 15 minutos
        usageTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            self.timeUsageAlert = true
        }
        print("Timer del Dashboard iniciado (15 min).")
    }

    private func stopUsageTimer() {
        usageTimer?.invalidate()
        usageTimer = nil
        print("Timer del Dashboard detenido.")
    }
    
    
    // --- 6. SUBVISTAS (Sin cambios) ---
    
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
        .confirmationDialog(
            "¿Qué deseas hacer?",
            isPresented: $viewModel.showingConfirmation,
            titleVisibility: .visible,
            presenting: viewModel.selectedGroup
        ) { group in
            Button("Comer 1 porción") {
                viewModel.consumePoint(for: group.id)
            }
            Button("Eliminar 1 porción", role: .destructive) {
                viewModel.addPortion(for: group.id)
            }
            Button("Ver ejemplos") {
                viewModel.showingExamplesSheet = true
            }
            Button("Cancelar", role: .cancel) { }
        }
        .sheet(isPresented: $viewModel.showingExamplesSheet) {
            if let group = viewModel.selectedGroup {
                ExampleSheetView(group: group)
                    .environmentObject(speechManager)
            }
        }
    }
}

// --- VISTA DE EJEMPLOS (Sin cambios) ---
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


// --- VISTA PREVIA (Sin cambios) ---
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(isMenuOpen: .constant(false), childAge: 5)
            .environmentObject(SpeechManager.shared)
    }
}
