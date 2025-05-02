import UIKit
import XLPagerTabStrip

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

class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var movies: [DiscoverMovieResult] = []
    var isLoadingMore = false
    var nextPage = 1
    
    func setMovies(_ newMovies: [DiscoverMovieResult]) {
        self.movies = newMovies
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func loadMoreData() {
        APICaller.shared.getDiscoverMovies(with: nextPage) { result in
            switch result {
            case .success(let moreMovies):
                self.movies.append(contentsOf: moreMovies)
                self.nextPage += 1
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.isLoadingMore = false
                }
            case .failure(let error):
                print("Failed to load more: \(error.localizedDescription)")
                self.isLoadingMore = false
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // Jika sudah mendekati bawah (misal 100pt dari bawah)
        if position > contentHeight - scrollViewHeight - 100 {
            guard !isLoadingMore else { return }
            isLoadingMore = true

            // Panggil API untuk load data berikutnya
            loadMoreData()
        }
    }
    
    override    init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        collectionView.register(PosterImageCell.self, forCellWithReuseIdentifier: PosterImageCell.identifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterImageCell.identifier, for: indexPath) as? PosterImageCell else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.item]
        if let posterPath = movie.posterPath {
            cell.configure(with: posterPath)
        }
        
        return cell
    }
    
    // Atur ukuran cell agar jadi 2 kolom
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 3 // 2 kolom => 3 spasi (kiri, tengah, kanan)
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
