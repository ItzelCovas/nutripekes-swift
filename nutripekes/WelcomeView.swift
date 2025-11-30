//
//  WelcomeView.swift
//  nutripekes
//
//  Created by Itzel Covarrubias on 24/11/25.
//
import SwiftUI

struct WelcomeView: View {
    @Binding var hasStarted: Bool

    var body: some View {
        ZStack {
            Color(red: 226/255, green: 114/255, blue: 101/255)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                Image("titulo")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 300)
                
                Spacer()
                
                Button(action: {
                    self.hasStarted = true
                }) {
                    VStack {
                        Image("manzana_bamx")
                            .resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80)
                        Text("Iniciar")
                            .font(.system(size: 50, weight: .bold, design: .rounded)).foregroundColor(.white)
                    }
                    .padding(.vertical, 20).padding(.horizontal, 60)
                    .background(Color(red: 243/255, green: 182/255, blue: 79/255))
                    .cornerRadius(40)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 8)
                }
                Spacer()
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(hasStarted: .constant(false))
    }
}
