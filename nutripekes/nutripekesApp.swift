import SwiftUI

@main
struct nutripekesApp: App {
    
    @AppStorage("childAge") var childAge: Int = 0
    @State private var hasStarted = false

    // 1. Crea la instancia compartida del "motor" de voz (TTS)
    @StateObject private var speechManager = SpeechManager.shared
    
    // 2. Ya no hay 'init()' ni 'requestNotificationPermission()'

    var body: some Scene {
        WindowGroup {
            
            // 3. Usamos un "Group" como contenedor
            Group {
                if childAge == 0 {
                    AgeSelectionView()
                } else {
                    if hasStarted {
                        NavigationView {
                            MainView(childAge: childAge)
                        }
                    } else {
                        WelcomeView(hasStarted: $hasStarted)
                    }
                }
            }
            // 4. Inyecta el motor de voz en el entorno
            //    para que todas las vistas (como InfoView) puedan usarlo.
            .environmentObject(speechManager)
        }
    }
}
