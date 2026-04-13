//
//  AccountModel.swift
//  Pathfinder
//
//  Created by EmreAluc on 17.02.2025.
//

import Foundation
import SwiftUI

class AccountModel: ObservableObject {
    @Published var errorMessage: String?
}

struct Favorite: Identifiable, Codable {
    var id: String
    var userId: String
    var storeId: String
    var productId: String
    var stockQuantity: Int
    var productPrice: Double
    var storeRating: Double
    var storeName: String
    var productName: String
    var timestamp: Date = Date()
}

struct ViewedItem: Identifiable, Codable {
    let id: String
    let productId: String
    let storeId: String
    let productName: String
    let storeName: String
    let stockPrice: Double
    let viewedAt: Date
}

