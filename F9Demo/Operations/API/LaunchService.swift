import Foundation

enum APIError: String, Error {
    case noDataAvailable = "No Data Avaialble"
    case unableToParseData = "Unable to parse data"
}

protocol LaunchServiceProtocol {
    static func fetchData(completion: @escaping (Result<[Launch], APIError>) -> ())
}

class LaunchService: LaunchServiceProtocol {
    static func fetchData(completion: @escaping (Result<[Launch], APIError>) -> ()) {
        guard let apiURL = URL(string: "https://api.spacexdata.com/v4/launches/") else {
            return
        }

        let request = URLRequest(url: apiURL)
        URLSession.shared.dataTask(with: request) { data, response, error  in
            if let _ = error {
                completion(.failure(APIError.noDataAvailable))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.unableToParseData))
                return
            }

            do {
                let decoder = JSONDecoder()
                let launches = try decoder.decode([Launch].self, from: data)
                completion(.success(launches))
            } catch let error {
                print("Fetch Error: \(error.localizedDescription)")
                completion(.failure(APIError.unableToParseData))
            }
        }.resume()
    }
}
