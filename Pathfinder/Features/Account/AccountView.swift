//
//  AccountView.swift
//  Pathfinder
//
//  Created by EmreAluc on 26.01.2025.
//

import SwiftUI

enum SelectiveAction: String, CaseIterable {
    case myFavorites
    case myHistory
}

struct AccountView: View {
    
    @Namespace private var underlineAnimation
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var favoriteService: FavoriteService
    @StateObject var accountModel = AccountModel()
    @StateObject var userSession = User()
    @State var selectedAction: SelectiveAction = .myFavorites
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.gray .opacity(0.3))
                    .padding(.leading)
                Text("Hello, \(userSession.name.isEmpty ? "User" : userSession.name) \(userSession.surname.isEmpty ? "" : userSession.surname)")
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Edit"){
                    
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
            }
            .padding()
            
            Divider()
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedAction = .myFavorites
                                print("datalar", favoriteService.userFavorites)
                            }
                        }){
                            Text ("My Favorites")
                                .frame(height: 50)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .fontWeight(.bold)
                            
                        }
                        .buttonStyle(PressedButonStyle())
                        
                        if selectedAction == .myFavorites {
                            Rectangle()
                                .frame(height: 3)
                                .foregroundStyle(Color.green)
                                .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                        } else {
                            Color.clear.frame(height: 3)
                        }
                    }
                    
                    Divider()
                        .frame(height: 53)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.spring()) {
                                selectedAction = .myHistory
                            }
                        }){
                            Text ("History")
                                .frame(height: 50)
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .fontWeight(.bold)
                            
                            
                        }
                        .buttonStyle(PressedButonStyle())
                        
                        if selectedAction == .myHistory {
                            Rectangle()
                                .frame(height: 3)
                                .foregroundStyle(Color.green)
                                .matchedGeometryEffect(id: "underline", in: underlineAnimation)
                        } else {
                            Color.clear.frame(height: 3)
                        }
                    }
                }
            }
            .frame(maxHeight: 53)
            .padding(.bottom)
            
            switch selectedAction {
                
            case .myFavorites:
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
                
            case .myHistory:
                Text("History coming soon...")
                    .padding()
                
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
                Image(systemName: "iphone.and.arrow.right.outward")
                    .font(.system(size: 25))
                    .foregroundColor(.red)
                    .fontWeight(.bold)
                    .frame(height: 50)
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
