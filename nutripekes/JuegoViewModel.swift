import Foundation
import SwiftUI
import AVFoundation

struct Personaje: Identifiable, Equatable {
    let id: String
    let name: String
    let imageName: String
}

struct FoodItem: Identifiable, Equatable {
    let id = UUID()
    var position: CGPoint
    let imageName: String
    let isGood: Bool
}

enum GameState {
    case seleccionPersonaje
    case instrucciones
    case countdown
    case jugando
    case gameOver
}

class JuegoViewModel: ObservableObject {
    
    @Published var gameState: GameState = .seleccionPersonaje
    @Published var foodItems: [FoodItem] = []
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var countdownText: String = "3"
    
    @Published var playerPosition: CGPoint = .zero
    @Published var selectedCharacter: Personaje? = nil
    
    let playerSize = CGSize(width: 220, height: 150)
    let foodSize = CGSize(width: 50, height: 50)
    
    private var gameTimer: Timer?
    private var countdownTimer: Timer?
    private var screenSize: CGSize = .zero
    
    private var audioPlayer: AVAudioPlayer? //musica de fondo
    private var sfxPlayer: AVAudioPlayer? //efectos de sonido
    private var successPlayer: AVAudioPlayer?
    
    private let goodFoodImages: [String] = [
        "brocoli_img",
        "manzana_img",
        "zanahoria_img",
        "fresa_img",
    ]
    
    private let badFoodImages: [String] = [
        "papitas_img",
        "soda_img",
    ]
    
    let personajes: [Personaje] = [
        Personaje(id: "niño", name: "Niño", imageName: "niño_personaje"),
        Personaje(id: "niña", name: "Niña", imageName: "niña_personaje")
    ]
    
    init() {
        setupMusic()
    }
    
    private func playErrorSound() {
        if sfxPlayer?.isPlaying == true {
            sfxPlayer?.stop()
            sfxPlayer?.currentTime = 0
        }
        sfxPlayer?.play()
    }
    
    private func playSuccessSound() {
        if successPlayer?.isPlaying == true {
            successPlayer?.stop()
            successPlayer?.currentTime = 0
        }
        successPlayer?.play()
    }
    
    private func setupMusic() {
        if let path = Bundle.main.path(forResource: "musica_fondo", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.volume = 0.5
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error al cargar la música: \(error)")
            }
        }
        
        if let sfxPath = Bundle.main.path(forResource: "error_sonido", ofType: "mp3") {
            do {
                sfxPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sfxPath))
                sfxPlayer?.volume = 1.0 // Volumen al máximo
                sfxPlayer?.prepareToPlay()
            } catch {
                print("Error al cargar el sonido de error: \(error)")
            }
        }
        
        if let successPath = Bundle.main.path(forResource: "correcto_sonido", ofType: "mp3") {
            do {
                successPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: successPath))
                successPlayer?.volume = 1.0 // Volumen al máximo
                successPlayer?.prepareToPlay()
            } catch {
                print("Error éxito: \(error)")
            }
        }
    }
    
    func selectCharacter(_ personaje: Personaje) {
        self.selectedCharacter = personaje
        self.gameState = .instrucciones
    }
    
    func startCountdown() {
        self.countdownText = "3"
        self.gameState = .countdown
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            let currentCount = Int(self.countdownText) ?? 1
            if currentCount > 1 {
                self.countdownText = "\(currentCount - 1)"
            } else {
                timer.invalidate()
                self.countdownTimer = nil
                self.startGame()
            }
        }
    }
    
    // Inicia el bucle principal del juego
    private func startGame() {
        self.gameState = .jugando
        audioPlayer?.play()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.gameLoop()
        }
    }
    
    func pauseGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        audioPlayer?.pause()
        print("Juego pausado.")
    }
    
    func resumeGame() {
        if gameState == .jugando && gameTimer == nil {
            print("Reanudando el juego.")
            audioPlayer?.play()
            gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.gameLoop()
            }
        }
    }
    
    func stopMusicCompletely() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
    }
    
    private func gameLoop() {
        for i in 0..<foodItems.count {
            foodItems[i].position.y += 6
        }
        if Double.random(in: 0...1) < 0.04 {
            spawnFood()
        }
        checkCollisions()
        foodItems.removeAll { $0.position.y > (self.screenSize.height + 50) }
        if lives <= 0 {
            endGame()
        }
    }
    
    // Detiene el juego
    private func endGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        gameState = .gameOver
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0 //reiniciar canción al principio
    }
    
    // Reinicia todo para volver a jugar
    func resetGame() {
        self.lives = 3
        self.score = 0
        self.foodItems.removeAll()
        self.playerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height - (playerSize.height / 2) - 50)
        self.gameState = .seleccionPersonaje
        audioPlayer?.prepareToPlay()
    }
    
    // Funciones de Lógica del Juego
    func setScreenSize(_ size: CGSize) {
        self.screenSize = size
        self.playerPosition = CGPoint(x: size.width / 2, y: size.height - (playerSize.height / 2) - 50)
    }
    
    func movePlayer(to newX: CGFloat) {
        let halfPlayer = playerSize.width / 2
        let newXClamped = max(halfPlayer, min(screenSize.width - halfPlayer, newX))
        self.playerPosition.x = newXClamped
    }
    

    private func spawnFood() {
        let isGoodFood = Bool.random()
        let foodImage: String
        
        if isGoodFood {
            foodImage = goodFoodImages.randomElement() ?? "brocoli_img"
        } else {
            foodImage = badFoodImages.randomElement() ?? "papitas_img"
        }
        
        let randomX = CGFloat.random(in: (foodSize.width / 2)...(screenSize.width - foodSize.width / 2))
        
        let newFood = FoodItem(position: CGPoint(x: randomX, y: -foodSize.height), imageName: foodImage, isGood: isGoodFood)
        foodItems.append(newFood)
    }
    
    // colisiones
    private func checkCollisions() {
        let hitboxScale: CGFloat = 0.6
    
        let reducedWidth = playerSize.width * hitboxScale
        let reducedHeight = playerSize.height * hitboxScale
        
        let playerRect = CGRect(
            x: playerPosition.x - reducedWidth / 2,
            y: playerPosition.y - reducedHeight / 2,
            width: reducedWidth,
            height: reducedHeight
        )

        for (index, food) in foodItems.enumerated().reversed() {
            let foodScale: CGFloat = 0.9
            let foodW = foodSize.width * foodScale
            let foodH = foodSize.height * foodScale
            
            let foodRect = CGRect(
                x: food.position.x - foodW / 2,
                y: food.position.y - foodH / 2,
                width: foodW,
                height: foodH
            )
        
            if playerRect.intersects(foodRect) {
                if food.isGood {
                    score += 10
                    // Lógica de recuperar vida (máximo 3)
                    if lives < 3 {
                        lives += 1
                    }
                    playSuccessSound()
                } else {
                    lives -= 1
                    playErrorSound()
                }
                foodItems.remove(at: index)
            }
        }
    }
}
