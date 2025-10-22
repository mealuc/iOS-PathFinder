
import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable {
    @DocumentID var id: String?
    var storeId: String
    var storeName: String
    var storeOwnerId: String
}

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var productId: String
    var productName: String
    var productCategory: String
}
