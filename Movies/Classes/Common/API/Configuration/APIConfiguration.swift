//
//  APIConfiguration.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation

enum MoviesAPI {
    case movieSearch(keyword:String, type:String, page:Int)
    
    func urlString() -> String {
        return NetworkConfiguration.api(self)
    }
    
    fileprivate func apiString() -> String {
        switch self {
        case .movieSearch(let keyword, let type, let page):
            return "s=\(keyword)&type=\(type)&page=\(page)&apikey=\(NetworkConfiguration.apiKeyOMCb)"
        }
    }
}


struct NetworkConfiguration {
    
    fileprivate static let baseUrlString = "http://www.omdbapi.com/?"
    fileprivate static let apiKeyOMCb = "791b884d"
    
    
    static func api(_ apiType: MoviesAPI) -> String {
        return baseUrlString + apiType.apiString()
    }
}
