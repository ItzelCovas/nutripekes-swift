//
//  AlertView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

struct AlertView: View {
    var body: some View {
        ZStack {
            // MARK: - capa 1:  fondo (la app principal)
            // Usamos una de las vistas existentes como fondo para dar contexto.
            FourthView()
            
            // MARK: - capa 2: sombreado semitransparente
            Color.white.opacity(0.6)
                .ignoresSafeArea()

            // MARK: - capa 3: tarjeta de alerta
            VStack {
                Text("Un ratito de movimiento hace que el juego sea aún más divertido después")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black) // Texto en color negro
                    .padding(30)
                    .background(Color(red: 243/255, green: 182/255, blue: 79/255)) // Color naranja
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            }
            //padding horizontal para controlar ancho de la tarjeta
            .padding(.horizontal, 40)
        }
    }
}


// MARK: - 
struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}
