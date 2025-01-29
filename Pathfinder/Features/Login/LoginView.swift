//  LoginView.swift
//  Pathfinder
//  Created by EmreAluc on 13.01.2025.

import SwiftUI

struct LoginView: View {
    @State private var password: String = ""
    @State private var message : String = ""
    @EnvironmentObject var appState : AppState
    var body: some View {
        NavigationView {
            VStack {
                
                Text("Login")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextField("Username", text: $appState.username)
                    .modifier(FieldModifier())
                
                SecureField("Password", text: $password)
                    .modifier(FieldModifier())
                
                Button("Login") {
                    userAuthanticate(username: appState.username, password: password)
                }
                .foregroundStyle(Color.white)
                .bold()
                .padding()
                .frame(width: 300, height: 40)
                .background(Color.blue)
                .cornerRadius(10)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.red)
                }
                
                Text("or")
                HStack {
                    Circle()
                        .frame(width: 50, height: 40)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .frame(width: 50, height: 40)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .frame(width: 50, height: 40)
                        .foregroundColor(Color.blue)
                }
                .padding(.bottom)
                
                Divider()
                
                Text("Don't have an account?")
                    .padding(.top)
                
                Button("Register") {
                    
                }
                .foregroundStyle(Color.blue)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(10)
                
            }
            .padding()
        }
        .navigationTitle("Login")
    }
    
    func userAuthanticate(username: String  , password: String) {
        if username.lowercased() == "test123" && password.lowercased() == "123" {
            appState.isLoggedIn = true
        }
        else{
            message = "Incorrect username or password!"
        }
    }
}

struct FieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 300, height: 40)
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
