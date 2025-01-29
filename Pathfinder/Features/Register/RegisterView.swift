//
//  RegisterView.swift
//  Pathfinder
//
//  Created by EmreAluc on 13.01.2025.
//

import SwiftUI

struct RegisterView: View {
    
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var birthdate = Date()
    
    var body: some View {
        NavigationView {
            VStack {

                Text("Register")
                    .font(.title)
                    .bold()
                    .padding()
                
                TextField("Name", text: $name)
                    .modifier(FieldModifier())
                
                TextField("Surname", text: $surname)
                    .modifier(FieldModifier())
                
                TextField("Username", text: $username)
                    .modifier(FieldModifier())
                
                TextField("Email", text: $email)
                    .modifier(FieldModifier())
                
                SecureField("Password", text: $password)
                    .modifier(FieldModifier())
                
                DatePicker("Birth Date",
                           selection: $birthdate,
                           in: ...Date(),
                           displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .frame(width: 300, height: 40)
                
                Button("Register") {
                    
                }
                .foregroundStyle(Color.white)
                .bold()
                .padding()
                .frame(width: 300, height: 40)
                .background(Color.blue)
                .cornerRadius(10)
                
            }
            .padding()
        }
        .navigationTitle("Login")
    }
}

#Preview {
    RegisterView()
}
