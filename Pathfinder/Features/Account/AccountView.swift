//
//  AccountView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var favoriteService: FavoriteService
    @StateObject var accountModel = AccountModel()
    @StateObject var userSession = User()
    
    var body: some View {
        VStack(spacing: 0){
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
            VStack{
                HStack(spacing: 0) {
                    //Bug var sadece textler buton görevi görüyor, tüm mavi alanın basılabilir olması gerekli
                    Button(action: {
                        print("My Favorites", favoriteService.userFavorites)
                    }){
                        Text ("My Favorites")
                            .frame(height: 50)
                            .foregroundStyle(Color(.white))
                    }
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .buttonStyle(PressedButonStyle())
                    
                    Divider()
                    
                    Button(action: {
                        print("History")
                    }){
                        Text ("History")
                            .frame(height: 50)
                            .foregroundStyle(Color(.white))
                    }
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .buttonStyle(PressedButonStyle())
                }
            }
            .frame(maxHeight: 50)
            .padding(.bottom)
            
            ScrollView(.vertical) {
                ForEach(favoriteService.userFavorites, id: \.id){ data in
                    let storeId = data.storeId
                    let productId = data.productId
                    
                    VStack{
                        Text(storeId)
                            .frame(height: 50, alignment: .center)
                            .frame(maxWidth: .infinity)

                        Text(productId)
                            .frame(height: 50)
                    }
                    .background(.blue)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                }
            }
            
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
        .environmentObject(FavoriteService())
}
