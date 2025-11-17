//
//  AccountModel.swift
//  Pathfinder
//
//  Created by EmreAluc on 17.02.2025.
//

import Foundation
import SwiftUI

class AccountModel: ObservableObject {
    @Published private var _errorMessage: String?
    
    var errorMessage: String? {
        get {
            _errorMessage
        } set {
            _errorMessage = newValue
        }
    }
}

struct Favorite: Identifiable, Codable {
    var id: String
    var userId: String
    var storeId: String
    var productId: String
    var timestamp: Date = Date()
}

