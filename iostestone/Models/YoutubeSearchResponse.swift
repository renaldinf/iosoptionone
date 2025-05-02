// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let youtubeSearchResponse = try? JSONDecoder().decode(YoutubeSearchResponse.self, from: jsonData)

import Foundation

// MARK: - YoutubeSearchResponse
struct YoutubeSearchResponse: Codable {
    let id: Int?
    let results: [YoutubeSearchResult]?
}

// MARK: - Result
struct YoutubeSearchResult: Codable {
    let iso639_1, iso3166_1, name, key: String?
    let site: String?
    let size: Int?
    let type: String?
    let official: Bool?
    let publishedAt, id: String?

    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}
