import XCTest
@testable import F9Demo

class F9DemoTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFetchDataReturnsLaunches() {
        let launchesExpectation = expectation(description: "launches")
        var launchesResponse: [Launch]?
        
        LaunchService.fetchData { result in
            switch result {
            case .success(let launches):
                launchesResponse = launches
                launchesExpectation.fulfill()
            case .failure: break
            }
        }
        
        waitForExpectations(timeout: 4) { (error) in
            XCTAssertNotNil(launchesResponse)
        }
    }
    
    func testFetchDataWithStubReturnsLaunches() {
        let json =
            """
        [
          {
            \"links\": {
              \"patch\": {
                \"small\": \"https://images2.imgbox.com/3c/0e/T8iJcSN3_o.png\",
                \"large\": \"https://images2.imgbox.com/40/e3/GypSkayF_o.png\"
              },
            },
            \"success\": false,
            \"flight_number\": 1,
            \"name": \"FalconSat\",
            \"date_utc\": \"2006-03-24T22:30:00.000Z\",
          },
        ]
        """
        let jsonData = json.data(using: .utf8)!
        let launchesExpectation = expectation(description: "launches")
        var launchesResponse: [Launch]?
        
        APIRepository.fetchData(jsonData) { result in
            switch result {
            case .success(let launches):
                launchesResponse = launches
                launchesExpectation.fulfill()
            case .failure: break
            }
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(launchesResponse)
        }
    }
    
    func testFetchDataWithStubReturnsError() {
        let json =
            """
        [
          {
            \"links\": {
              \"patch\": {
                \"small\": \"https://images2.imgbox.com/3c/0e/T8iJcSN3_o.png\",
                \"large\": \"https://images2.imgbox.com/40/e3/GypSkayF_o.png\"
              },
            },
            \"success\": false,
            \"flight_number\": 1,
            \"name": nil,
            \"date_utc\": \"2006-03-24T22:30:00.000Z\",
          },
        ]
        """
        let jsonData = json.data(using: .utf8)!
        let errorExpectation = expectation(description: "error")
        var errorResponse: APIError?
        
        APIRepository.fetchData(jsonData) { result in
            switch result {
            case .success:
                break;
            case .failure(let error):
                errorResponse = error
                errorExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorResponse)
        }
    }
    
    func testFetchDataWithStubWhenDataNil() {
        let errorExpectation = expectation(description: "error")
        var errorResponse: APIError?
        
        APIRepository.fetchData(nil) { result in
            switch result {
            case .success:
                break;
            case .failure(let error):
                errorResponse = error
                errorExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorResponse)
        }
    }

    func testFetchDataWithInvalidStubReturnsError() {
        let json =
            """
        [
          {
            \"links\": {
              \"patch\": {
                \"small\": \"https://images2.imgbox.com/3c/0e/T8iJcSN3_o.png\",
                \"large\": \"https://images2.imgbox.com/40/e3/GypSkayF_o.png\"
              },
            },
            \"success\": false,
            \"flight_number\": 1,
            \"name": \"FalconSat\",
            \"date_utc\",
          },
        ]
        """
        let jsonData = json.data(using: .utf8)!
        let errorExpectation = expectation(description: "error")
        var errorResponse: APIError?
        
        APIRepository.fetchData(jsonData) { result in
            switch result {
            case .success:
                break;
            case .failure(let error):
                errorResponse = error
                errorExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(errorResponse)
        }
    }

}

class APIRepository {
    static func fetchData(_ stub: Data?, _ completion: @escaping (Result<[Launch], APIError>) -> ()) {
        do {
            let decoder = JSONDecoder()
            let launches = try decoder.decode([Launch].self, from: stub ?? Data())
            completion(.success(launches))
        } catch let error {
            print("Fetch Error: \(error.localizedDescription)")
            completion(.failure(APIError.unableToParseData))
        }
    }
}

