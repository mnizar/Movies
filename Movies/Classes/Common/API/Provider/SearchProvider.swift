//
//  SearchProvider.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation
import RxSwift

enum SearchType: String{
    case movie = "movie"
    case tvShow = "series"
}

class SearchProvider {
    
    func fetchSearch(keyword:String, type:SearchType, page:Int) -> Observable<SearchResponseModel?> {
        let percentageEncodingKeyword = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let searchUrl = MoviesAPI.movieSearch(keyword: percentageEncodingKeyword, type: type.rawValue, page: page).urlString()
        return APIProvider().get(searchUrl).map { response in
            
            if let data = response as? Data {
                do {
                    let decode = try JSONDecoder().decode(SearchResponseModel.self, from: data)
                    return decode
                } catch let error {
                    print(error)
                }
            }  else {
                print("response not Data")
            }
            return nil
        }
    }
    
}
