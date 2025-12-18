//
//  RegisterView.swift
//  Pathfinder
//
//  Created by EmreAluc on 13.01.2025.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var user = User()
    @StateObject var registerModel = RegisterModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Register")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextField("Name", text: $user.name)
                    .modifier(FieldModifier())
                
                TextField("Surname", text: $user.surname)
                    .modifier(FieldModifier())
                
                TextField("Username", text: $user.username)
                    .modifier(FieldModifier())
                
                TextField("Email", text: $user.email)
                    .modifier(FieldModifier())
                
                SecureField("Password", text: $user.password)
                    .modifier(FieldModifier())
                
                DatePicker("Birth Date",
                           selection: $user.birthdate,
                           in: ...Date(),
                           displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .frame(width: 300, height: 40)
                
                Button(action: {
                    RegisterService.userRegister(user: user, registerModel: registerModel) { success in
                        if success {
                            dismiss()
                        }
                    }
                }) {
                    Text("Register")
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                        .frame(width: 300, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                if let errorMessage = registerModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .frame(width: 300)
                }
                
                    Button("Already have an account?"){
                        dismiss()
                    }
                
                    Spacer()
                
                Button(action: {
                    
                }){
                    Text("I WANT TO BE SELLER")
                        .frame(width: 200)
                        .padding(5)
                        .foregroundStyle(Color.blue)
                        .bold()
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        }
                    }
                }
            .padding()
        }
        .navigationTitle("Login")
    }
}

#Preview {
    RegisterView()
}
