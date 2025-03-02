//
//  RegisterModel.swift
//  Pathfinder
//
//  Created by EmreAluc on 24.02.2025.
//

import Foundation

class User: ObservableObject {
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var birthdate = Date()
}

class RegisterModel: ObservableObject {
    @Published private var _errorMessage: String?
    
    var errorMessage: String? {
        get {
            _errorMessage
        } set {
            _errorMessage = newValue
        }
    }
}
