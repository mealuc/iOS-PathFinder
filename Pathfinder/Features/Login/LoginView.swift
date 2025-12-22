//  LoginView.swift
//  Pathfinder
//  Created by EmreAluc on 13.01.2025.

import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var appState : AppState
    @StateObject var loginModel = LoginModel()
    @EnvironmentObject var historyService: HistoryService
    @State private var showRegisterView : Bool = false
    
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
                    AuthService.shared.loginWithEmail(
                        email: loginModel.email,
                        password: loginModel.password
                    ) { result in
                        switch result {
                        case .success:
                            loginModel.errorMessage = nil
                            if let uid = Auth.auth().currentUser?.uid {
                                historyService.getHistory(for: uid)
                            }
                            appState.isLoggedIn = true
                            
                        case .failure(let error):
                            loginModel.errorMessage = error.localizedDescription
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
                HStack(spacing: 32) {
                    
                    Button {
                        let rootVC = UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .first?
                            .windows
                            .first?
                            .rootViewController
                        
                        if let rootVC {
                            AuthService.shared.signInWithGoogle(rootVC: rootVC) { success in
                                if success {
                                    appState.isLoggedIn = true
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "g.circle.fill")
                            .foregroundColor(Color.blue)
                            .padding(.vertical, 4)
                            .font(.system(size: 35))
                    }
                    
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: AuthService.shared.prepareAppleRequest,
                        onCompletion: AuthService.shared.handleAppleLogin
                    )
                    .frame(maxWidth: 150)
                    .frame(height: 40)
                    .cornerRadius(10)
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
