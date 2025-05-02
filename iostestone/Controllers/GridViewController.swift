import UIKit

class GridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    weak var delegate: CollectionViewTableViewCellDelegate?
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let movie = movies[indexPath.row]
        guard let id = movie.id else {return}
        guard let titleName = movie.title  ?? movie.originalTitle else {return}
        
        let group = DispatchGroup()
        var movieDetail: DetailMovieResponse?
        var movieVideos: [YoutubeSearchResult] = []
        var movieReviews: [ReviewResult] = []
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        
        group.enter()
        APICaller.shared.getDetailsMovie(with: id) { result in
            switch result {
            case .success(let detail):
                movieDetail = detail
            case .failure(let error):
                print("Detail error:", error)
            }
            group.leave()
        }
        
        group.enter()
        APICaller.shared.getYoutubeTrailer(with: id) { result in
            switch result {
            case .success(let videos):
                movieVideos = videos.results ?? []
            case .failure(let error):
                print("Videos error:", error)
            }
            group.leave()
        }
        
        group.enter()
        APICaller.shared.getMovieReview(with: id) { result in
            switch result {
            case .success(let reviews):
                movieReviews = reviews.results ?? []
            case .failure(let error):
                print("Reviews error:", error)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            loadingIndicator.stopAnimating()
            loadingIndicator.removeFromSuperview()
            
            //                guard let strongSelf = self else {return}
            let viewModel = MovieInfoModel(detail: movieDetail, video: movieVideos, reviews: movieReviews)
            //                self?.delegate?.collectionViewTableViewCellDidTapCell(strongSelf, viewModel: viewModel)
            DispatchQueue.main.async { [weak self] in
                loadingIndicator.stopAnimating()
                loadingIndicator.removeFromSuperview()
                let vc = MovieInfoController()
                vc.configure(with: viewModel)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
