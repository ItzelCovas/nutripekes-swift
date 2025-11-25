import SwiftUI

@main
struct nutripekesApp: App {
    
    @AppStorage("childAge") var childAge: Int = 0
    @State private var hasStarted = false

    @StateObject private var speechManager = SpeechManager.shared

    var body: some Scene {
        WindowGroup {
            
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
            .environmentObject(speechManager)
        }
    }
}
