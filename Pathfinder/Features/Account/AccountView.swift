//
//  AccountView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState : AppState
    @StateObject var accountModel = AccountModel()
    @StateObject var userSession = User()
    
    var body: some View {
        VStack{
            HStack{
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.gray .opacity(0.3))
                    .padding(.leading)
                Text("Hello, \(userSession.name.isEmpty ? "Kullanıcı" : userSession.name) \(userSession.surname.isEmpty ? "" : userSession.surname)")
                Spacer()
                Button("Edit"){
                    
                }
                .foregroundStyle(.blue)
            }
            .padding()
            Divider()
            Spacer()
            
            if let errorMessage = accountModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .frame(width: 300)
                    .padding(.bottom)
            }

            Button(action: {
                AccountService.logout(accountModel: accountModel) { result in
                    if result {
                        appState.isLoggedIn = false
                    }
                }
            }) {
                Text("Log out")
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .frame(height: 30)
            }
        }
        .onAppear(){
            AccountService.getUserData(user: userSession, accountModel: accountModel)
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(AppState())
        .environmentObject(AccountModel())
}
