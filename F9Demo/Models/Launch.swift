import Foundation

struct Launch: Decodable {
    struct Links: Decodable {
        struct Patch: Decodable {
            let small: String?
            let large: String?
        }
        
        let patch: Patch?
    }
    
    let id: Int
    let name: String
    let date: String
    let success: Bool?
    let links: Links?
    
    enum CodingKeys: String, CodingKey {
        case id = "flight_number"
        case date = "date_utc"
        case name
        case success
        case links
    }
}
