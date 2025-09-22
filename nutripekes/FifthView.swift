//
//  FifthView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 21/09/25.
//

import SwiftUI

// La vista del menú no necesita cambios.
struct MenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            
            // Sección de Padres
            HStack {
                Text("Padres")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.top, 100)
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Tabla de recomendaciones")
                Text("Recetario")
            }
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(.leading, 20)
            .padding(.top, 10)

            //sección de info
            HStack {
                Text("Información")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                Image(systemName: "chevron.down")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 18) {
                Text("Componentes de una\ncomida balanceada")
                Text("Señales de hambre y\nsaciedad")
                Text("Manejo de la\nselectividad\nalimentaria")
            }
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(.white)
            .padding(.leading, 20)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding(.horizontal, 25)
        .frame(maxWidth: .infinity, alignment: .leading) //alineado a la izquierda.
        .background(Color(red: 65/255, green: 78/255, blue: 51/255).opacity(0.9))
        .edgesIgnoringSafeArea(.all)
    }
}


// Vista que controla la aparición del menú
struct FifthView: View {
    @State private var isMenuOpen = true
    
    var body: some View {
        ZStack(alignment: .leading) { //ZStack a la izquierda
            
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()
            
            FourthView()

            if isMenuOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // isMenuOpen = false
                    }
            }
            
            MenuView()
                .frame(width: 270) //ancho fijo para el menú
                .offset(x: isMenuOpen ? 0 : -270) // Se desplaza en base a su ancho
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isMenuOpen)
    }
}

// MARK: - Vista Previa
struct FifthView_Previews: PreviewProvider {
    static var previews: some View {
        FifthView()
    }
}
