//
//  ThirdView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

struct ThirdView: View {
    var body: some View {
        ZStack {
            // MARK: - Fondo
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            VStack {
                // MARK: - barra
                HStack {
                    Image(systemName: "line.horizontal.3")
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                    Image("titulo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // MARK: - Imagen
                Image("Manzana2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 280)

                Spacer()

                // MARK: - Contadores
                VStack {
                    // Fila superior de contadores
                    HStack(alignment: .top, spacing: 15) {
                        // Pasamos los nuevos valores de 'count' y 'progress'
                        CounterCircleView(
                            labelText: "Verduras y\nfrutas",
                            borderColor: .green,
                            count: 2,
                            progress: 0.4 // del 40%
                        )
                        CounterCircleView(
                            labelText: "Origen\nanimal",
                            borderColor: Color(red: 239/255, green: 83/255, blue: 80/255),
                            count: 1,
                            progress: 0.2
                        )
                        CounterCircleView(
                            labelText: "Leguminosas",
                            borderColor: .orange,
                            count: 1,
                            progress: 0.25
                        )
                        CounterCircleView(
                            labelText: "Cereales",
                            borderColor: .yellow,
                            count: 4,
                            progress: 0.8
                        )
                    }

                    // Contador de agua
                    CounterCircleView(
                        labelText: "Vasos de agua",
                        borderColor: .cyan,
                        count: 3,
                        progress: 0.6 
                    )
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
    }
}





// MARK: - Vista Previa
struct ThirdView_Previews: PreviewProvider {
    static var previews: some View {
        ThirdView()
    }
}
