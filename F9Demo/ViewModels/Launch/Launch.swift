import Foundation

struct Launch: Decodable {
    struct Links: Decodable {
        struct Patch: Decodable {
            let small: String?
            let large: String?
        }
        
        let patch: Patch?
    }
    
    let name: String
    let date: String
    let success: Bool?
    let links: Links?
    
    enum CodingKeys: String, CodingKey {
        case date = "date_utc"
        case name
        case success
        case links
    }
}
