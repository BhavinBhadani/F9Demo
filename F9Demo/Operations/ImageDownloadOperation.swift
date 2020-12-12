import Foundation

class ImageDownloadOperation: BaseOperation<Bool> {
    private static var imageCache: NSCache<NSString,NSData> = {
        var cache = NSCache<NSString,NSData>()
        cache.countLimit = 50
        return cache
    }()

    var urlString: String
    var imageView: ImageView?
    var cache: Bool
    
    init(urlString: String, imageView: ImageView, scale: Bool = false, cache: Bool = false) {
        self.urlString = urlString
        self.imageView = imageView
        self.cache = cache

        super.init()
        
        // Hotfix for images to comply with ATS
        self.urlString = self.urlString.replacingOccurrences(of: "http://", with: "https://")
    }
    
    static func cachedImage(url: String) -> NSData? {
        return ImageDownloadOperation.imageCache.object(forKey: url as NSString)
    }
    
    override func main() {
        let urlString = self.urlString
        guard let url = URL(string: urlString) else {
            finish(withErrorMessage: "Unable to process url.")
            return
        }
        
        if let data = ImageDownloadOperation.imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async { [weak self] in
                self?.imageView?.set(data: data as Data)
                self?.finish(withResult: true)
            }
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.imageView?.reset()
        }
        
        let urlRequest = URLRequest(url: url)
        let operation = URLRequestOperation(urlRequest: urlRequest)
        
        operation.completion = { [weak self] (data, error) in
            guard self?.isCancelled == false else {
                self?.finish(withErrorMessage: "Cancelled.")
                return
            }
            
            DispatchQueue.main.async {
                if let data = data {
                    ImageDownloadOperation.imageCache.setObject(data as NSData, forKey: urlString as NSString)
                    self?.imageView?.set(data: data)
                    self?.finish(withResult: true)
                } else if let error = error {
                    self?.finish(withError: error)
                } else {
                    self?.finish(withErrorMessage: "Could not download image data.")
                }
            }
        }
        
        internalOperationQueue.addOperation(operation)
    }
}
