import Alamofire
import Foundation

struct Constants {
    static let API_KEY = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjJhYzM4NzU0YjcxNThkNWU0M2MwMjE3NzMxMGM5YiIsIm5iZiI6MTc0NjEzMDY2Ny4yNiwic3ViIjoiNjgxM2Q2ZWI0M2E2MmY4NjVmZTAyODM2Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.AoboCOD0YYmtzRJSOCwhicS9jxLaymWoHQwVvCck1dA"
    static let baseURL = "https://api.themoviedb.org/3/"
    static let YoutubeAPI_KEY = "AIzaSyAyp2mtPVdcOnm4yt3hJsdfpWUipBEbxfw"
    static let YoutubeBaseURL = "https://www.googleapis.com/youtube/v3/search?"
}

enum APIError: Error {
    case failedToGetData
}

class APICaller {
    static let shared = APICaller()

    
    func getDiscoverMovies(with page: Int, completion: @escaping (Result<[DiscoverMovieResult], Error>) -> Void) {
        let url = "\(Constants.baseURL)discover/movie"
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.API_KEY)"
        ]
        
        let parameters: Parameters = [
            "language": "en-US"
        ]
        
        AF.request(url, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: DiscoverMovieResponse.self) { response in
                switch response.result {
                case .success(let model):
                    completion(.success(model.results ?? []))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func getDetailsMovie(with id: Int, completion: @escaping (Result<DetailMovieResponse, Error>) -> Void)  {
        let url = "\(Constants.baseURL)movie/\(id)"
        let headers: HTTPHeaders = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.API_KEY)"
        ]
        
        let parameters: Parameters = [
            "language": "en-US"
        ]
        
        AF.request(url, parameters: parameters, headers: headers)
            .validate()
            .responseDecodable(of: DetailMovieResponse.self) { response in
                switch response.result {
                case .success(let model):
                    completion(.success(model))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
