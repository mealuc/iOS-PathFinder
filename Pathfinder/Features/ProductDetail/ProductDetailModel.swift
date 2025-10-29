import Foundation
import FirebaseFirestore

struct ProductStock: Decodable, Identifiable {
    @DocumentID var id: String?
    var productId: String
    var stockQuantity: Int
    var storeId: String
    var storeName: String
    var productPrice: Double
}
