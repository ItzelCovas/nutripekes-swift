import SwiftUI

struct CounterCircleView: View {
    let labelText: String
    let borderColor: Color // color "activo"
    let count: Int
    let progress: Double // va de 0.0 (vacío) a 1.0 (lleno)

    private let inactiveColor = Color(.systemGray3)
    private let aCompletadoColor = Color.green // Color para el estado final

    var body: some View {
        VStack {
            ZStack {
                                
                // Definimos los estados
                let isFinished = count == 0
                let dynamicBorderColor = isFinished ? aCompletadoColor : inactiveColor

                Circle().fill(.white)
                
                Circle()
                    .stroke(inactiveColor.opacity(0.5), lineWidth: 10)

                if progress > 0 {
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                        .stroke(borderColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear(duration: 0.5), value: progress)
                }
                
                Circle().stroke(dynamicBorderColor, lineWidth: 6)
                
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
            
            Text(labelText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
    }
}
