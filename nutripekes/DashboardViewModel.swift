import Foundation
import SwiftUI

// --- Almacenamiento Local (Memoria) ---
class DailyProgressStorage {
    @AppStorage("lastSavedDate") static var lastSavedDate: String = ""
    @AppStorage("progressVerduras") static var progressVerduras: Int = -1
    @AppStorage("progressAnimal") static var progressAnimal: Int = -1
    @AppStorage("progressLeguminosas") static var progressLeguminosas: Int = -1
    @AppStorage("progressCereales") static var progressCereales: Int = -1
    @AppStorage("progressAgua") static var progressAgua: Int = -1
    
    static func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// --- Modelos de Datos ---
struct FoodExample: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
}

struct FoodGroup: Identifiable {
    let id: String
    var name: String
    var color: Color
    var targetPoints: Int
    var remainingPoints: Int
    var examples: [FoodExample]
}


class DashboardViewModel: ObservableObject {
    
    @Published var foodGroups: [FoodGroup] = [] // Inicia vacío
    
    // Estados para los menús
    @Published var selectedGroup: FoodGroup?
    @Published var showingConfirmation: Bool
    @Published var showingExamplesSheet: Bool

    
    init(age: Int) {
        self.showingConfirmation = false
        self.showingExamplesSheet = false
        self.selectedGroup = nil
        
        self.reloadData(for: age, forceReset: false)
    }
    
    func reloadData(for age: Int, forceReset: Bool = false) {
        
        print("Recargando datos para la edad: \(age). Forzar Reseteo: \(forceReset)")
        
        let targetPortions = DashboardViewModel.getPortions(for: age)
        let today = DailyProgressStorage.getTodayString()
        let lastSaved = DailyProgressStorage.lastSavedDate
        let isNewDay = (today != lastSaved)

        let shouldResetProgress = isNewDay || DailyProgressStorage.progressVerduras == -1 || forceReset
        
        self.foodGroups = [
            FoodGroup(
                id: "verduras", name: "Verduras y\nfrutas", color: .green,
                targetPoints: targetPortions["verduras"]!,
                remainingPoints: shouldResetProgress ? targetPortions["verduras"]! : DailyProgressStorage.progressVerduras,
                examples: [
                    FoodExample(name: "Zanahoria", emoji: "🥕"),
                    FoodExample(name: "Brócoli", emoji: "🥦"),
                    FoodExample(name: "Naranja", emoji: "🍊"),
                    FoodExample(name: "Plátano", emoji: "🍌"),
                    FoodExample(name: "Manzana", emoji: "🍎")
                ]
            ),
            FoodGroup(
                id: "animal", name: "Origen\nanimal", color: Color(red: 239/255, green: 83/255, blue: 80/255),
                targetPoints: targetPortions["animal"]!,
                remainingPoints: shouldResetProgress ? targetPortions["animal"]! : DailyProgressStorage.progressAnimal,
                examples: [
                    FoodExample(name: "Pollo", emoji: "🍗"),
                    FoodExample(name: "Pescado", emoji: "🐟"),
                    FoodExample(name: "Huevo", emoji: "🥚"),
                    FoodExample(name: "Queso", emoji: "🧀"),
                    FoodExample(name: "Carne", emoji: "🥩")
                ]
            ),
            FoodGroup(
                id: "leguminosas", name: "Leguminosas", color: .orange,
                targetPoints: targetPortions["leguminosas"]!,
                remainingPoints: shouldResetProgress ? targetPortions["leguminosas"]! : DailyProgressStorage.progressLeguminosas,
                examples: [
                    FoodExample(name: "Frijoles", emoji: "🫘"),
                    FoodExample(name: "Lentejas", emoji: "🥘"),
                    FoodExample(name: "Maní", emoji: "🥜")
                ]
            ),
            FoodGroup(
                id: "cereales", name: "Cereales", color: .yellow,
                targetPoints: targetPortions["cereales"]!,
                remainingPoints: shouldResetProgress ? targetPortions["cereales"]! : DailyProgressStorage.progressCereales,
                examples: [
                    FoodExample(name: "Tortilla", emoji: "🌮"),
                    FoodExample(name: "Avena", emoji: "🥣"),
                    FoodExample(name: "Pan", emoji: "🍞"),
                    FoodExample(name: "Arroz", emoji: "🍚")
                ]
            ),
            FoodGroup(
                id: "agua", name: "Vasos de agua", color: .cyan,
                targetPoints: targetPortions["agua"]!,
                remainingPoints: shouldResetProgress ? targetPortions["agua"]! : DailyProgressStorage.progressAgua,
                examples: [
                    FoodExample(name: "Agua Natural", emoji: "💧")
                ]
            )
        ]
        
        if shouldResetProgress {
            saveProgress()
            DailyProgressStorage.lastSavedDate = today
        }
    }
    
    
    var appleImageName: String {
        
        // Convertimos a Double para calcular el porcentaje
        let totalTargetPoints = Double(foodGroups.reduce(0) { $0 + $1.targetPoints })
        let totalRemaining = Double(foodGroups.reduce(0) { $0 + $1.remainingPoints })
        
        // Evitar división por cero si no hay objetivos
        if totalTargetPoints == 0 {
            return "manzana4" // Si el objetivo es 0, está completo
        }
        
        let totalConsumed = totalTargetPoints - totalRemaining
        let completionPercentage = totalConsumed / totalTargetPoints
        
        // Ahora, mapeamos el porcentaje a las 5 imágenes
        
        if totalRemaining == 0 {
            // Estado 5: 100% completo
            return "manzana4" // Roja y feliz
            
        } else if completionPercentage > 0.66 {
            // Estado 4: 67% - 99% completo
            return "manzana3" // Naranja y sonriente
            
        } else if completionPercentage > 0.33 {
            // Estado 3: 34% - 66% completo
            return "manzana2" // Amarilla y neutral
            
        } else if completionPercentage > 0 {
            // Estado 2: 1% - 33% completo
            return "manzana1" // Verde-amarilla y neutral
            
        } else {
            // Estado 1: 0% completo (no ha comido nada)
            return "manzana0" // Verde y triste
        }
    }

    func consumePoint(for groupID: String) {
        if let index = foodGroups.firstIndex(where: { $0.id == groupID }) {
            if foodGroups[index].remainingPoints > 0 {
                foodGroups[index].remainingPoints -= 1
                saveProgress()
            }
        }
    }
    
    func addPortion(for groupID: String) {
        if let index = foodGroups.firstIndex(where: { $0.id == groupID }) {
            if foodGroups[index].remainingPoints < foodGroups[index].targetPoints {
                foodGroups[index].remainingPoints += 1
                saveProgress()
            }
        }
    }

    func saveProgress() {
        for group in foodGroups {
            switch group.id {
            case "verduras": DailyProgressStorage.progressVerduras = group.remainingPoints
            case "animal": DailyProgressStorage.progressAnimal = group.remainingPoints
            case "leguminosas": DailyProgressStorage.progressLeguminosas = group.remainingPoints
            case "cereales": DailyProgressStorage.progressCereales = group.remainingPoints
            case "agua": DailyProgressStorage.progressAgua = group.remainingPoints
            default: break
            }
        }
    }
    
    static func getPortions(for age: Int) -> [String: Int] {
        switch age {
        case 3...5:
            return [
                "verduras": 3, "animal": 2, "leguminosas": 1, "cereales": 4, "agua": 5
            ]
        case 6...8:
            return [
                "verduras": 4, "animal": 2, "leguminosas": 2, "cereales": 5, "agua": 6
            ]
        case 9...10:
            return [
                "verduras": 5, "animal": 3, "leguminosas": 2, "cereales": 6, "agua": 8
            ]
        default:
            return [
                "verduras": 5, "animal": 3, "leguminosas": 2, "cereales": 6, "agua": 8
            ]
        }
    }
}
