import Foundation

struct MovieInfoModel {
    var detail: DetailMovieResponse?
    var video: [YoutubeSearchResult] = []
    var reviews: [ReviewResult] = []
}
