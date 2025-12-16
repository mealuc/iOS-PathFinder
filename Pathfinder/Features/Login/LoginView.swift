//  LoginView.swift
//  Pathfinder
//  Created by EmreAluc on 13.01.2025.

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState : AppState
    @StateObject var loginModel = LoginModel()
    @State private var showRegisterView : Bool = false
    @State var authService = AuthService()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Login")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextField("Email", text: $loginModel.email)
                    .modifier(FieldModifier())
                
                SecureField("Password", text: $loginModel.password)
                    .modifier(FieldModifier())
                
                Button(action: {
                    authService.userLoginAuthanticate(email: loginModel.email, password: loginModel.password, loginModel: loginModel) { result in
                        if result {
                            appState.isLoggedIn = true
                        }
                    }
                }) {
                    Text("Login")
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                        .frame(width: 300, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                if let errorMessage = loginModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(width: 300)
                }
                
                Text("or")
                
                Button {
                    authService.signInWithGoogle() { result in
                        if result {
                            appState.isLoggedIn = true
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(Color.blue)
                    }
                    .padding(.vertical, 4)
                    .font(.system(size: 35))
                }
                
                Divider()
                
                Text("Don't have an account?")
                    .padding(.top)
                
                Button (action: {showRegisterView = true}) {
                    Text("Register")
                        .foregroundColor(Color.blue)
                }
                .padding()
                
            }
            .padding()
        }
        .navigationTitle("Login")
        .fullScreenCover(isPresented: $showRegisterView){
            RegisterView()
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
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
        .environmentObject(LoginModel())
}
