import UIKit

class LaunchTableViewCell: UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
    enum MissionStatusImage {
        static let success = UIImage(named: "ic_success")
        static let failed = UIImage(named: "ic_failed")
        static let unknown = UIImage(named: "ic_unknown")
    }
    
    private var launchImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var missionNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()

    private var missionDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    private var missionSuccessLabel: UILabel = {
        let label = UILabel()
        label.text = "Mission Success:"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private var missionSuccessImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var missionSuccessSpacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var successStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubViews() {
        addSubview(launchImageView)
        addSubview(missionNameLabel)
        addSubview(missionDateLabel)
        addSubview(successStackView)
        
        successStackView.addArrangedSubview(missionSuccessLabel)
        successStackView.addArrangedSubview(missionSuccessImageView)
        successStackView.addArrangedSubview(missionSuccessSpacerView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            launchImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            launchImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            launchImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            launchImageView.widthAnchor.constraint(equalTo: launchImageView.heightAnchor, multiplier: 1),

            missionNameLabel.leadingAnchor.constraint(equalTo: launchImageView.trailingAnchor, constant: 16),
            missionNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 10),
            missionNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            missionDateLabel.leadingAnchor.constraint(equalTo: missionNameLabel.leadingAnchor, constant: 0),
            missionDateLabel.trailingAnchor.constraint(equalTo: missionNameLabel.trailingAnchor, constant: 0),
            missionDateLabel.topAnchor.constraint(equalTo: missionNameLabel.bottomAnchor, constant: 8),
            
            successStackView.leadingAnchor.constraint(equalTo: missionDateLabel.leadingAnchor, constant: 0),
            successStackView.trailingAnchor.constraint(equalTo: missionDateLabel.trailingAnchor, constant: 0),
            successStackView.topAnchor.constraint(equalTo: missionDateLabel.bottomAnchor, constant: 8),
            
            missionSuccessImageView.heightAnchor.constraint(equalToConstant: 20),
            missionSuccessImageView.widthAnchor.constraint(equalToConstant: 20),
            missionSuccessSpacerView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    var launch: Launch? {
        didSet {
            guard let launch = launch else { return }
            missionNameLabel.text = launch.name
            
            let missionDate = launch.date.toDate("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").toString("MM-dd-yyyy")
            missionDateLabel.text = "Launch Date: \(missionDate)"
            
            launchImageView.image = nil
            if let links = launch.links, let patch = links.patch, let img = patch.small {
                ImageController.default.downloadAndCache(urlString: img, imageView: launchImageView)
            }
            
            missionSuccessImageView.image = MissionStatusImage.unknown
            guard let missionStatus = launch.success else { return }
            missionSuccessImageView.image = missionStatus ? MissionStatusImage.success : MissionStatusImage.failed
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        launchImageView.image = nil
    }

}
