//
//  LoginModel.swift
//  Pathfinder
//
//  Created by EmreAluc on 17.02.2025.
//

import Foundation

class LoginModel: ObservableObject {
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var errorMessage: String?
    
}
