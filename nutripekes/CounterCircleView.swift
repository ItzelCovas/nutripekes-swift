import SwiftUI

struct CounterCircleView: View {
    let labelText: String
    let borderColor: Color // Este es el color "activo" (ej. verde, naranja)
    let count: Int
    let progress: Double // Ahora va de 0.0 (vacío) a 1.0 (lleno)

    private let inactiveColor = Color(.systemGray3)
    private let aCompletadoColor = Color.green // Color para el estado final

    var body: some View {
        VStack {
            ZStack {
                                
                // 1. Definimos los estados
                let isFinished = count == 0

                // 2. Color del BORDE EXTERIOR:
                // Será gris (inactiveColor) todo el tiempo,
                // EXCEPTO al final, que será verde para coincidir con la palomita.
                let dynamicBorderColor = isFinished ? aCompletadoColor : inactiveColor

                // 3. Fondo blanco sólido.
                Circle().fill(.white)
                
                // 4. La PISTA de fondo (El círculo gris que siempre se ve)
                Circle()
                    .stroke(inactiveColor.opacity(0.5), lineWidth: 10)

                // 5. El RELLENO (La barra de progreso de color)
                // Sigue la lógica anterior: se dibuja si progress > 0
                // y usa el color principal del grupo (borderColor).
                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(borderColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.5), value: progress)
                }
                
                // 6. El BORDE EXTERIOR (Usa la nueva lógica)
                Circle().stroke(dynamicBorderColor, lineWidth: 6)
                
                // 7. El NÚMERO o la PALOMITA.
                if isFinished { // Se muestra cuando el contador llega a 0
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(aCompletadoColor) // Verde
                } else {
                    Text("\(count)") // Muestra porciones restantes
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
            }
            .frame(width: 80, height: 80)
            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 5)
            
            // Etiqueta de texto (sin cambios)
            Text(labelText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
    }
}
