import Foundation
import UIKit

class LaunchViewModel: NSObject {
    var launches = [Launch]()
    var viewModelUpdated: ((_ status: Bool) -> ())?
    
    override init() {
        super.init()
        
        LaunchService.fetchData { result in
            DispatchQueue.main.async {
                LoadingOverlays.removeAllBlockingOverlays()
            }
            switch result {
            case .success(let data):
                self.launches = data
                self.viewModelUpdated?(true)
            case .failure(let e):
                print(e.rawValue)
            }
        }
    }
}

//MARK: UITableViewDataSource
extension LaunchViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return launches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LaunchTableViewCell.identifier,
                                                       for: indexPath) as? LaunchTableViewCell else{
            fatalError("UITableViewCell must be downcasted to LaunchTableViewCell")
        }
        
        cell.launch = launches[indexPath.row]
        return cell
    }
}
