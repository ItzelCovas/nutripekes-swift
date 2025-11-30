import AVFoundation
import SwiftUI

class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    
    // Instancia única (Singleton) para usarla en toda la app
    static let shared = SpeechManager()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    // Variables para saber qué está pasando
    @Published var isSpeaking: Bool = false
    @Published var currentID: String? = nil // Guardamos el ID del alimento que suena
    
    override init() {
        super.init()
        synthesizer.delegate = self // IMPORTANTE: Para saber cuándo termina de hablar
    }
    
    func speak(text: String, id: String) {
        // 1. Lógica de Toggle:
        // Si ya está hablando Y es el mismo botón que pulsamos -> Lo callamos
        if isSpeaking && currentID == id {
            stop()
            return
        }
        
        // 2. Si estaba hablando otro distinto, lo callamos primero
        stop()
        
        // 3. Configuramos el nuevo audio
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") // Español México
        utterance.rate = 0.5
        
        // 4. Actualizamos el estado para que el botón cambie a PAUSA
        self.currentID = id
        self.isSpeaking = true
        
        synthesizer.speak(utterance)
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        // Reseteamos las variables para que el botón vuelva a ser SPEAKER
        self.isSpeaking = false
        self.currentID = nil
    }
    
    // Delegado: Se ejecuta automáticamente cuando el audio termina solo
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.isSpeaking = false
        self.currentID = nil
    }
}
