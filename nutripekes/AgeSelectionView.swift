//
//  AgeSelectionView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 12/11/25.
//

import SwiftUI

struct AgeSelectionView: View {
    @AppStorage("childAge") var childAge: Int = 0
    @State private var selectedAge = 3 // edad mínima

    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                Image("titulo")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 300)
                
                Text("¡Bienvenido!\nSelecciona la edad de tu peque:")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 3. Picker para seleccionar la edad
                Picker("Edad", selection: $selectedAge) {
                    ForEach(3...10, id: \.self) { age in
                        Text("\(age) años").tag(age)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .pickerStyle(.wheel)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .padding(.horizontal, 40)
                
                // 4. Botón para guardar la edad
                Button(action: {

                    self.childAge = selectedAge
                }) {
                    Text("Guardar y Empezar")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 65/255, green: 78/255, blue: 51/255))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 243/255, green: 182/255, blue: 79/255))
                        .cornerRadius(20)
                        .padding(.horizontal, 40)
                }
                Spacer()
                Spacer()
            }
        }
    }
}

struct AgeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        AgeSelectionView()
    }
}
