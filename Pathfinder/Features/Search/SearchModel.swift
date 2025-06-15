
import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable {
    @DocumentID var id: String?
    var storeId: String
    var storeName: String
    var storeOwnerId: String
}
