//
//  PadresView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

struct PadresView: View {
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // MARK: - Barra
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
                    Text("Padres")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.bottom, 10)
                    
                    // MARK: Recomendaciones
                    Image("tabla")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                        .shadow(radius: 5)
                    
                    // MARK: Recetario
                    Image("receta")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - 
struct PadresView_Previews: PreviewProvider {
    static var previews: some View {
        PadresView()
    }
}
