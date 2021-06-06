//
//  SearchResultModel.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation
import RealmSwift

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
class SearchModel: Object, Codable {
    @objc dynamic var title: String?
    @objc dynamic var year: String?
    @objc dynamic var imdbID: String?
    @objc dynamic var type: String?
    @objc dynamic var posterUrl: String?
    
    //Inverse to SearchResults.
    let searchResults = LinkingObjects(fromType: SearchResult.self, property: "items")
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case posterUrl = "Poster"
    }
}


class SearchResult: Object {
     
    @objc dynamic var keyword = ""
    @objc dynamic var type = ""
    let items = List<SearchModel>()  //one-to-many
     
    override static func primaryKey() -> String? {
        return "keyword"
    }
     
    
}
