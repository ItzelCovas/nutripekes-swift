import Foundation
import AVFoundation

class SpeechManager: ObservableObject {
    
    static let shared = SpeechManager()
    private var synthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
