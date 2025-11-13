//
//  GuiaUsoView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 12/11/25.
//

import SwiftUI

struct GuiaUsoView: View {
    
    // 1. Obtenemos el motor de voz
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        ZStack {
            // Fondo de color
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    Text("Guía de Uso")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 20)

                    // Sección 1
                    GuiaSectionView(
                        titulo: "1. El Dashboard",
                        icono: "house.fill",
                        descripcion: "Esta es tu pantalla principal. Aquí puedes ver el progreso diario de tu peque."
                    )
                    
                    // Sección 2
                    GuiaSectionView(
                        titulo: "2. Los Contadores",
                        icono: "circle.grid.cross.fill",
                        descripcion: "Cada círculo representa un grupo de alimentos. Toca un círculo para ver las opciones."
                    )
                    
                    // Sección 3
                    GuiaSectionView(
                        titulo: "3. Opciones (Comer, Ver, Eliminar)",
                        icono: "list.bullet",
                        descripcion: "Al tocar un círculo, puedes:\n• **Comer 1 porción:** Resta 1 al contador.\n• **Eliminar 1 porción:** Regresa 1 porción si te equivocaste.\n• **Ver ejemplos:** Muestra una lista de alimentos de ese grupo."
                    )
                    
                    // Sección 4
                    GuiaSectionView(
                        titulo: "4. La Manzanita",
                        icono: "face.smiling.fill",
                        descripcion: "La manzana cambiará su carita de triste a feliz conforme tu peque complete sus porciones del día."
                    )
                    
                    // Sección 5
                    GuiaSectionView(
                        titulo: "5. Menú Lateral (☰)",
                        icono: "line.horizontal.3",
                        descripcion: "Toca las tres rayas para abrir el menú. Desde aquí puedes acceder a la sección de 'Padres' (recetas y tablas) e 'Información'."
                    )
                    
                    // *****
                    // ***** 2. NUEVA SECCIÓN AÑADIDA AQUÍ *****
                    // *****
                    GuiaSectionView(
                        titulo: "6. Lector de Voz (TTS)",
                        icono: "speaker.wave.2.fill",
                        descripcion: "Toca el ícono de la bocina (🔉) al lado de cualquier texto para que la app lo lea en voz alta. ¡Perfecto para cuando los peques aún están aprendiendo a leer!"
                    )
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Guía de Uso")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            Color(red: 226/255, green: 114/255, blue: 101/255),
            for: .navigationBar
        )
        // 3. Detiene la voz si el usuario sale de esta pantalla
        .onDisappear {
            speechManager.stop()
        }
    }
}

// 4. Una vista auxiliar para que cada tarjeta de guía se vea bien
// (Esta struct no cambia, pero es necesaria en el archivo)
struct GuiaSectionView: View {
    var titulo: String
    var icono: String
    var descripcion: String
    
    // Obtenemos el motor de voz para la bocina de la guía
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icono)
                    .font(.title2)
                    .frame(width: 30)
                Text(titulo)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Spacer()
                
                // 5. Botón de bocina para cada sección de la guía
                Button(action: {
                    let textoCompleto = "\(titulo). \(descripcion)"
                    speechManager.speak(text: textoCompleto)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.body)
                        .foregroundColor(Color(red: 65/255, green: 78/255, blue: 51/255))
                }
            }
            .foregroundColor(Color(red: 65/255, green: 78/255, blue: 51/255)) // Verde oscuro

            Text(descripcion)
                .font(.system(size: 17, design: .rounded))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(radius: 3)
    }
}

// Vista Previa
struct GuiaUsoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GuiaUsoView()
                // 6. Añade esto para que la Vista Previa funcione
                .environmentObject(SpeechManager.shared)
        }
    }
}
