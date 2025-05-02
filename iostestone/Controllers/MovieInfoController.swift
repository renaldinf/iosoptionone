import UIKit
import WebKit

class MovieInfoController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.text = "Harry Potter"
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.text = "Magic & School"
        return label
    }()
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starRatingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.starRatingLabel, self.ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.addSubview(titleLabel)
        view.addSubview(overviewLabel)
        view.addSubview(ratingView)
        
        configureConstraints()
    }
    
    func configureConstraints(){
        let webViewConstraints = [
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.heightAnchor.constraint(equalToConstant: 300)
        ]
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let overviewLabelConstraints = [
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        let ratingViewConstraints = [
            ratingView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 10),
            ratingView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(webViewConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(overviewLabelConstraints)
        NSLayoutConstraint.activate(ratingViewConstraints)
    }
    
    func configure(with model: MovieInfoModel){
        titleLabel.text = model.detail?.title ?? model.detail?.originalTitle
        overviewLabel.text = model.detail?.overview
        let youtubeKey = model.video.first?.key ?? ""
        
        let intRatings = model.reviews.compactMap { $0.authorDetails?.rating }
        let ratings = intRatings.map { Double($0) }
        let averageRating = ratings.isEmpty ? 0.0 : ratings.reduce(0.0, +) / Double(ratings.count)
        let stars = String(repeating: "⭐️", count: Int(averageRating))
        starRatingLabel.text = "\(stars) (\(averageRating)/10)"
        
        guard let url = URL(string: "https://www.youtube.com/embed/\(youtubeKey)") else {return}
        
        webView.load(URLRequest(url: url))
    }
}
