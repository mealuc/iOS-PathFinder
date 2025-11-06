
import Foundation
import FirebaseFirestore

struct Store: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var storeId: String
    var storeName: String
    var storeOwnerId: String
    var storeAddress: String
    var storeCity: String
    var storeState: String
    var storeZip: String
    var storePhone: String
    var storeEmail: String
    var storeLatitude: Double
    var storeLongitude: Double
    var storeRating: Double
    var storeLastUpdated: Date?
}

struct Product: Identifiable, Codable {
    @DocumentID var id: String?
    var productId: String
    var productName: String
    var productCategory: String
}
