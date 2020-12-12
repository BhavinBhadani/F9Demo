import Foundation

class URLRequestOperation: BaseOperation<Data> {
    var urlRequest: URLRequest

    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
        super.init()
    }

    override func main() {
        let session = URLSession.shared
        let request = self.urlRequest

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.handleDataTaskResponse(data: data, response: response, error: error)
        }

        task.resume()
        session.flush {}
    }

    func isSuccessStatusCode(_ statusCode: Int) -> Bool {
        return statusCode >= 200 && statusCode < 300
    }

    func isErrorStatusCode(_ statusCode: Int) -> Bool {
        return !isSuccessStatusCode(statusCode)
    }

    private func handleDataTaskResponse(data: Data?, response: URLResponse?, error: Swift.Error?) {
        guard !isCancelled else {
            finish(withErrorMessage: "Operation was cancelled.")
            return
        }

        if let error = error {
            finish(withError: error)
        } else if let response = response as? HTTPURLResponse, isErrorStatusCode(response.statusCode) {
            finish(withErrorMessage: "HTTP request returned unexpected status code: \(response.statusCode).")
        } else if let data = data {
            finish(withResult: data)
        } else {
            finish(withErrorMessage: "Invalid HTTP request responses.")
        }
    }
}
