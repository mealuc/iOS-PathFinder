//
//  LoginModel.swift
//  Pathfinder
//
//  Created by EmreAluc on 17.02.2025.
//

import Foundation

class LoginModel: ObservableObject {
    @Published var password: String = ""
    @Published private var _errorMessage: String?
    
    var errorMessage: String? {
        get {
            _errorMessage
        } set {
            _errorMessage = newValue
        }
    }
}
