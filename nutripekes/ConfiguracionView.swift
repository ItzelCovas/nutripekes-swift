//
//  ConfiguracionView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 12/11/25.
//

import SwiftUI

struct ConfiguracionView: View {
    // 1. Se conecta a la misma variable de memoria local
    @AppStorage("childAge") var childAge: Int = 0
    
    // 2. Un estado local para que el picker no guarde
    //    la edad hasta que presiones "Guardar"
    @State private var selectedAge: Int = 3
    
    // 3. Para poder cerrar la vista
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("Configurar Edad")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                Text("La edad actual es: \(childAge) años")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))

                // 4. Picker para seleccionar la nueva edad
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
                
                // 5. Botón para guardar y salir
                Button(action: {
                    // Guardar la nueva edad en la memoria local
                    childAge = selectedAge
                    // Cerrar la vista de Configuración
                    dismiss()
                }) {
                    Text("Guardar Cambios")
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
            // 6. Carga la edad actual en el picker cuando la vista aparece
            .onAppear {
                self.selectedAge = childAge
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            Color(red: 226/255, green: 114/255, blue: 101/255),
            for: .navigationBar
        )
    }
}

struct ConfiguracionView_Previews: PreviewProvider {
    static var previews: some View {
        // Envolvemos en NavigationView para la vista previa
        NavigationView {
            ConfiguracionView()
        }
    }
}
