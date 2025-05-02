import UIKit

class MainScreen: UIViewController{
    private var discoverMovies: [DiscoverMovieResult]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        
        let gridLayout = UICollectionViewFlowLayout()
        let gridVC = GridViewController(collectionViewLayout: gridLayout)
        
        configureNavbar()
        
        APICaller.shared.getDiscoverMovies(with: 1) { data in
            switch data {
            case .success(let results):
                gridVC.setMovies(results)
                
                self.addChild(gridVC)
                //                gridVC.view.frame = self.view.bounds
                self.view.addSubview(gridVC.view)
                gridVC.didMove(toParent: self)
            case .failure(let error):
                print("Failed getDiscoverMovies \(error.localizedDescription)")
            }
        }
    }
    
    private func configureNavbar(){
        var image = UIImage(named: "netflixLogo")
        image = image?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "person"), style: .done, target: self, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "play.rectangle"), style: .done, target: self, action: nil)
        ]
        navigationController?.navigationBar.tintColor = .white
    }
}

extension MainScreen: CollectionViewTableViewCellDelegate {
    func collectionViewTableViewCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: MovieInfoModel) {
        DispatchQueue.main.async { [weak self] in
            let vc = MovieInfoController()
            vc.configure(with: viewModel)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
