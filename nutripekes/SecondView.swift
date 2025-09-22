//
//  SecondView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

struct SecondView: View {
    var body: some View {
        ZStack {
            // MARK: - Fondo
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            VStack {
                // MARK: - barra arriba
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

                // MARK: - Imagen Principal
                // La manzana triste, para el estado inicial
                Image("Manzana1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 280)

                Spacer()

                // MARK: - Contadores en estado inicial
                VStack {
                    HStack(alignment: .top, spacing: 15) {
                        CounterCircleView(
                            labelText: "Verduras y\nfrutas",
                            borderColor: .white,
                            count: 0,
                            progress: 0.0
                        )
                        CounterCircleView(
                            labelText: "Origen\nanimal",
                            borderColor: .white,
                            count: 0,
                            progress: 0.0
                        )
                        CounterCircleView(
                            labelText: "Leguminosas",
                            borderColor: .white,
                            count: 0,
                            progress: 0.0
                        )
                        CounterCircleView(
                            labelText: "Cereales",
                            borderColor: .white,
                            count: 0,
                            progress: 0.0
                        )
                    }

                    CounterCircleView(
                        labelText: "Vasos de agua",
                        borderColor: .white,
                        count: 0,
                        progress: 0.0
                    )
                    .padding(.top, 10)
                }
                
                Spacer()
            }
        }
    }
}


// MARK: - Vista Previa
struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        SecondView()
    }
}
