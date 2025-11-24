import Foundation
import SwiftUI

// (Las structs FoodItem, Personaje y GameState se quedan igual)
struct Personaje: Identifiable, Equatable {
    let id: String
    let name: String
    let imageName: String // "niño_personaje" o "niña_personaje"
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

// --- 2. El ViewModel (El Cerebro) ---
class JuegoViewModel: ObservableObject {
    
    // --- Propiedades del Estado del Juego ---
    @Published var gameState: GameState = .seleccionPersonaje
    @Published var foodItems: [FoodItem] = []
    @Published var lives: Int = 3
    @Published var score: Int = 0
    @Published var countdownText: String = "3"
    
    // --- Propiedades del Jugador ---
    @Published var playerPosition: CGPoint = .zero
    @Published var selectedCharacter: Personaje? = nil
    
    let playerSize = CGSize(width: 120, height: 150)
    let foodSize = CGSize(width: 50, height: 50)
    
    // --- Propiedades Privadas ---
    private var gameTimer: Timer?
    private var countdownTimer: Timer?
    private var screenSize: CGSize = .zero
    
    
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
    
    
    //  3. Lista de Personajes Disponibles
    let personajes: [Personaje] = [
        Personaje(id: "niño", name: "Niño", imageName: "niño_personaje"),
        Personaje(id: "niña", name: "Niña", imageName: "niña_personaje")
    ]
        
    // (Llamado desde la vista de selección)
    func selectCharacter(_ personaje: Personaje) {
        self.selectedCharacter = personaje
        self.gameState = .instrucciones
    }
    
    // (Llamado desde la vista de instrucciones)
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
        
        // El "motor" del juego
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.gameLoop()
        }
    }
    
    // Pausa el motor del juego
    func pauseGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        print("Juego pausado.")
    }
    
    // Reanuda el motor del juego
    func resumeGame() {
        if gameState == .jugando && gameTimer == nil {
            print("Reanudando el juego.")
            gameTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
                self?.gameLoop()
            }
        }
    }
    
    // Se ejecuta en cada "tick" del motor
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
    }
    
    // Reinicia todo para volver a jugar
    func resetGame() {
        self.lives = 3
        self.score = 0
        self.foodItems.removeAll()
        self.playerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height - (playerSize.height / 2) - 100)
        self.gameState = .seleccionPersonaje
    }
    
    // --- 5. Funciones de Lógica del Juego ---
    
    // (Llamado desde la Vista)
    func setScreenSize(_ size: CGSize) {
        self.screenSize = size
        self.playerPosition = CGPoint(x: size.width / 2, y: size.height - (playerSize.height / 2) - 100)
    }
    
    // (Llamado desde el DragGesture)
    func movePlayer(to newX: CGFloat) {
        let halfPlayer = playerSize.width / 2
        let newXClamped = max(halfPlayer, min(screenSize.width - halfPlayer, newX))
        self.playerPosition.x = newXClamped
    }
    

    // Añade una nueva comida en una X aleatoria
    private func spawnFood() {
        let isGoodFood = Bool.random()
        let foodImage: String
        
        if isGoodFood {
            // Elige una comida BUENA al azar de la lista
            // El '?? "brocoli_img"' es por seguridad, si la lista estuviera vacía
            foodImage = goodFoodImages.randomElement() ?? "brocoli_img"
        } else {
            // Elige una comida MALA al azar de la lista
            foodImage = badFoodImages.randomElement() ?? "papitas_img"
        }
        
        let randomX = CGFloat.random(in: (foodSize.width / 2)...(screenSize.width - foodSize.width / 2))
        
        let newFood = FoodItem(position: CGPoint(x: randomX, y: -foodSize.height), imageName: foodImage, isGood: isGoodFood)
        foodItems.append(newFood)
    }    
    
    // Detección de colisiones
    private func checkCollisions() {
        let playerRect = CGRect(
            x: playerPosition.x - playerSize.width / 2,
            y: playerPosition.y - playerSize.height / 2,
            width: playerSize.width,
            height: playerSize.height
        )
        
        for (index, food) in foodItems.enumerated().reversed() {
            let foodRect = CGRect(
                x: food.position.x - foodSize.width / 2,
                y: food.position.y - foodSize.height / 2,
                width: foodSize.width,
                height: foodSize.height
            )
            
            if playerRect.intersects(foodRect) {
                if food.isGood {
                    score += 10
                } else {
                    lives -= 1
                }
                foodItems.remove(at: index)
            }
        }
    }
}
