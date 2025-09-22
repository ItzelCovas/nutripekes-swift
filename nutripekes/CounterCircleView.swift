//
//  CounterCircleView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

// Este es nuestro componente reutilizable en su propio archivo.
struct CounterCircleView: View {
    let labelText: String
    let borderColor: Color
    let count: Int
    let progress: Double

    var body: some View {
        VStack {
            ZStack {
                Circle().fill(.white)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(borderColor, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                Circle().stroke(borderColor, lineWidth: 6)
                
                Text("\(count)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
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

// La vista previa es útil para ver el componente de forma aislada
struct CounterCircleView_Previews: PreviewProvider {
    static var previews: some View {
        // Puedes previsualizar diferentes estados
        HStack(spacing: 20) {
            CounterCircleView(labelText: "Ejemplo 1", borderColor: .green, count: 0, progress: 0.0)
            CounterCircleView(labelText: "Ejemplo 2", borderColor: .blue, count: 5, progress: 0.75)
        }
        .padding()
        .background(Color(red: 226/255, green: 114/255, blue: 101/255))
    }
}
