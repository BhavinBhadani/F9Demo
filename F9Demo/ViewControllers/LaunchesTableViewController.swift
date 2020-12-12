import UIKit

class LaunchesTableViewController: UITableViewController {
    private let viewModel = LaunchViewModel()
    private let rowHeight: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleView()
        configureTableView()
        
        LoadingOverlays.showBlockingWaitOverlay()
        viewModel.viewModelUpdated = { _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupTitleView() {
        let titleLabel = UILabel()
        titleLabel.text = "Falcon 9 Launches"
        titleLabel.textAlignment = .center
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }

    private func configureTableView() {
        tableView.dataSource = viewModel
        tableView.register(LaunchTableViewCell.self, forCellReuseIdentifier: LaunchTableViewCell.identifier)
        tableView.rowHeight = rowHeight
        tableView.tableFooterView = UIView()
    }
}
