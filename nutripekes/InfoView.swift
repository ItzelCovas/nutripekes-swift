//
//  InfoView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

// Pequeña estructura para organizar el contenido de cada tarjeta
struct InfoItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

// Componente reutilizable para las tarjetas de información
struct InfoCardView: View {
    let cardTitle: String
    let cardColor: Color
    let items: [InfoItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(cardTitle)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(item.description)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardColor)
        .foregroundColor(.white)
        .cornerRadius(20)
    }
}


// Vista principal que contiene todo
struct InfoView: View {
    // Datos para la primera tarjeta
    let componentesItems = [
        InfoItem(title: "Frutas y Verduras", description: "Aportan abundantes vitaminas, minerales, fibra y antioxidantes y son la base fundamental para el buen funcionamiento y desarrollo del organismo. Fortalecen el sistema inmunológico y mejoran la digestión."),
        InfoItem(title: "Origen Animal y Leguminosas", description: "Contienen proteínas, que son esenciales para la formación y reparación de tejidos, y para el crecimiento muscular. También contribuyen al desarrollo físico y al mantenimiento de los músculos, especialmente en los niños."),
        InfoItem(title: "Cereales", description: "Son la principal fuente de energía (carbohidratos), fibra, vitaminas y minerales. Son los que proveen la energía necesaria para las actividades diarias del cuerpo.")
    ]
    
    // Datos para la segunda tarjeta
    let senalesItems = [
        InfoItem(title: "Señales de hambre", description: "El niño puede buscar activamente la comida, abrir la boca, o succionar con más entusiasmo del pecho o biberón."),
        InfoItem(title: "Señales de saciedad", description: "El niño puede apartarse, cerrar la boca, no aceptar más comida, o escupir."),
        InfoItem(title: "Importancia", description: "Respetar estas señales permite al niño desarrollar un vínculo saludable con la comida, aprendiendo a reconocer sus propias necesidades.")
    ]
    
    // Datos para la tercera tarjeta
    let manejoItems = [
        InfoItem(title: "El rol de los padres", description: "Los padres son el principal modelo a seguir; por lo tanto, deben mostrar y practicar hábitos alimentarios saludables."),
        InfoItem(title: "Evitar la obligación", description: "Forzar a un niño a comer puede generar una situación emocional negativa y dañar la relación con la comida."),
        InfoItem(title: "Establecer rutinas", description: "Crear un horario regular de comidas y refrigerios ayuda a establecer hábitos.")
    ]

    var body: some View {
        ZStack {
            // Color de fondo principal
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // MARK: - Barra de Navegación Superior
                    HStack {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "arrow.left")
                                Text("Volver a niño")
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .font(.headline)
                        }
                        
                        Spacer()
                        
                        Image("titulo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                    }
                    
                    // MARK: - Título
                    Text("Información")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    // MARK: - Tarjetas de content
                    InfoCardView(
                        cardTitle: "Componentes de una comida balanceada",
                        cardColor: Color(red: 200/255, green: 80/255, blue: 70/255), // Rojo oscuro
                        items: componentesItems
                    )
                    
                    InfoCardView(
                        cardTitle: "Señales de hambre y saciedad",
                        cardColor: Color(red: 65/255, green: 78/255, blue: 51/255), // Verde oscuro
                        items: senalesItems
                    )
                    
                    InfoCardView(
                        cardTitle: "Manejo de la selectividad alimentaria",
                        cardColor: Color(red: 243/255, green: 182/255, blue: 79/255), // Naranja/amarillo
                        items: manejoItems
                    )
                }
                .padding()
            }
        }
    }
}

// MARK: - Vista Previa
struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
