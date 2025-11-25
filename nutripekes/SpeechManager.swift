import Foundation
import AVFoundation //framework de Audio/Video de Apple

//clase que se puede compartir en toda la app
class SpeechManager: ObservableObject {
    
    //la instancia compartida (Singleton)
    static let shared = SpeechManager()
    
    // "motor" real que habla
    private var synthesizer = AVSpeechSynthesizer()
    
    // función principal que llamarán tus botones
    func speak(text: String) {
        // Detiene cualquier cosa que estuviera hablando antes
        stop()
        
        // 5. Configura lo que va a decir
        let utterance = AVSpeechUtterance(string: text)
        
        // 6. Configura el idioma. "es-MX" es Español (México).
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        
        // 7. Configura la velocidad (0.5 es normal, 0.4 es más lento)
        utterance.rate = 0.4
        
        // 8. ¡Habla!
        synthesizer.speak(utterance)
    }
    
    // 9. Función para detener la voz
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
