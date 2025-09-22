//
//  FourthView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

struct FourthView: View {
    var body: some View {
        ZStack {
            // MARK:
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            VStack {
                // MARK:
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

                // MARK: - png
                Image("Manzana3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 280)

                Spacer()

                // MARK: -
                VStack {
                    // Fila superior de contadores
                    HStack(alignment: .top, spacing: 15) {
                        // Todos con progreso al 1.0 (100%)
                        CounterCircleView(
                            labelText: "Verduras y\nfrutas",
                            borderColor: .green,
                            count: 5, // número sigue ahí por si decidimos mostrarlo en el futuro
                            progress: 1.0 //completo
                        )
                        CounterCircleView(
                            labelText: "Origen\nanimal",
                            borderColor: Color(red: 239/255, green: 83/255, blue: 80/255),
                            count: 3,
                            progress: 1.0
                        )
                        CounterCircleView(
                            labelText: "Leguminosas",
                            borderColor: .orange,
                            count: 2,
                            progress: 1.0
                        )
                        CounterCircleView(
                            labelText: "Cereales",
                            borderColor: .yellow,
                            count: 6,
                            progress: 1.0
                        )
                    }

                    // Contador de agua
                    CounterCircleView(
                        labelText: "Vasos de agua",
                        borderColor: .cyan,
                        count: 6,
                        progress: 1.0
                    )
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
    }
}


// MARK: - Vista Previa
struct FourthView_Previews: PreviewProvider {
    static var previews: some View {
        FourthView()
    }
}
