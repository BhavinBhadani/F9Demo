import Foundation

typealias BaseOperationCompletion<T> = ((_ result: T?, _ error: Error?) -> Void)

@objc
private enum OperationState: Int {
    case ready
    case executing
    case finished
}

enum Warning: Error {
    case message(String)
    
    var localizedDescription: String {
        switch self {
        case .message(let warning):
            return warning
        }
    }
}

class StatefulOperation: Operation {
    var error: Error?

    // MARK: - Properties
    // Concurrent queue for synchronizing access to `state`.
    private let stateQueue = DispatchQueue(
        label: "com.F9Demo.state",
        attributes: .concurrent
    )

    // Private backing stored property for `state`.
    private var rawState: OperationState = .ready

    // The state of the operation
    @objc private dynamic var state: OperationState {
        get { return stateQueue.sync { rawState } }
        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
    }

    // MARK: - `Operation` properties
    open  override var isReady: Bool { return state == .ready && super.isReady }
    final override var isExecuting: Bool { return state == .executing }
    final override var isFinished: Bool { return state == .finished }
    final override var isAsynchronous: Bool { return true }

    // MARK: - KVN for dependent properties
    @objc
    private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc
    private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [#keyPath(state)]
    }

    @objc
    private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [#keyPath(state)]
    }

    // MARK: - Foundation.Operation
    final override func start() {
        guard !isCancelled else { return }

        state = .executing
        main()
    }

    // MARK: - Public
    // Subclasses must override the main function. First level subclasses cannot call super.
    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }
    
    internal func finish() {
        if isExecuting { state = .finished }
    }
}

class BaseOperation<T>: StatefulOperation {
    var completion: BaseOperationCompletion<T>?

    lazy var internalOperationQueue = OperationQueue()

    func operationCompletion<R>(warningOnError: String? = nil, process: @escaping ((R) -> Void)) -> ((R?, Error?) -> Void) {
        return { [weak self] (result: R?, error: Error?) in
            self?.handle(result: result, error: error, warningOnError: warningOnError, process: process)
        }
    }
    
    func handle<R>(result: R?, error: Error?, warningOnError: String? = nil, process: ((R) -> Void)) {
        if let error = error {
            if let warningOnError = warningOnError {
                finish(withWarningMessage: warningOnError)
            } else {
                finish(withError: error)
            }
        }
        else if let result = result {
            process(result)
        } else {
            finish(withErrorMessage: "Unable to process unexpected operation result.")
        }
    }
    
    // Called when the operation is complete
    func finish(withResult result: T) {
        self.finish(result: result, error: nil)
    }
    
    func finish(withWarningMessage warningMessage: String) {
        self.finish(
            result: nil,
            error: Warning.message(warningMessage)
        )
    }
    
    func finish(withErrorMessage errorMessage: String) {
        self.finish(
            result: nil,
            error: NSError.with(errorMessage: errorMessage)
        )
    }
    
    func finish(withError error: Error) {
        // Override internet connection appears to be offline error message.
        let nserror = error as NSError
        guard !(nserror.domain == NSURLErrorDomain && nserror.code == -1009) else {
            finish(withErrorMessage: "You don’t currently have access to wifi or cellular service. Please try to Sync again when you have connectivity.")
            return
        }
        
        finish(withErrorMessage: error.localizedDescription)
    }
    
    internal func finish(result: T?, error: Error?) {
        self.error = error

        if !isCancelled {
            completion?(result, error)
        }

        finish()
    }
}

extension NSError {
    static func with(errorMessage: String) -> NSError {
        return NSError(domain: "com.F9Demo", code: 0, userInfo: [
            NSLocalizedDescriptionKey: errorMessage
        ])
    }
}
