//
//  SearchResultModel.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation

struct SearchResponseModel: Codable {
    let search: [SearchModel]?
    let response: String?
    let totalResults : String?
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case response = "Response"
        case totalResults
        case error = "Error"
    }
}

// MARK: - SearchResultModel
struct SearchModel: Codable {
    let title: String?
    let year: String?
    let imdbID: String?
    let type: String?
    let posterUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case posterUrl = "Poster"
    }
}
