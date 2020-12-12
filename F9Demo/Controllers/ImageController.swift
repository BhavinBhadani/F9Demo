import Foundation
import UIKit

protocol ImageView {
    func reset()
    func set(data: Data)
    var hash: Int { get }
}

extension UIImageView: ImageView {
    func reset() {
        self.image = nil
    }

    func set(data: Data) {
        self.image = UIImage(data: data)
    }
}

class ImageController {
    private let operationQueue = OperationQueue()

    static let `default` = ImageController()
    private init() {}
    
    func download(urlString: String, imageView: ImageView) {
        let operation = ImageDownloadOperation(urlString: urlString, imageView: imageView)
        operationQueue.addOperation(operation)
    }
    
    func downloadAndCache(urlString: String, imageView: ImageView) {
        let operation = ImageDownloadOperation(urlString: urlString, imageView: imageView, cache: true)
        operationQueue.addOperation(operation)
    }
    
    func cancelDownloads(imageView: ImageView, ifNotForUrlString urlString: String) {
        for operation in operationQueue.operations {
            if let imageOperation = operation as? ImageDownloadOperation, imageOperation.imageView?.hash == imageView.hash, imageOperation.urlString != urlString {
                imageOperation.cancel()
            }
        }
    }
}
