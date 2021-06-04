//
//  APIProvider.swift
//  Movies
//
//  Created by Muhammad Nizar on 04/06/21.
//

import Foundation
import RxSwift


enum LoadingState : Int {
    case notLoad
    case loading
    case finished
    case failed
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
}

private enum Error: Swift.Error {
    case invalidResponse(URLResponse?)
    case invalidJSON(Swift.Error)
    case invalidData
}

class APIProvider {
    
    func get(_ urlString: String, params: [String: Any]? = [:], bodyParams: [String: Any]? = nil, headerRequest: [String: String]? = nil) -> Observable<Any?> {
        return requestWithMethod(.get, urlString: urlString, params: params, bodyParams: bodyParams, headerRequest: headerRequest)
    }
    
    fileprivate func requestWithMethod(_ method: HTTPMethod, urlString: String, params: [String: Any]?, bodyParams: [String: Any]? = nil, headerRequest: [String: String]? = nil) -> Observable<Any?> {
        return Observable<Any?>.create({ (observer) -> Disposable in
            do {
                guard let url = URL(string: urlString) else {
                    observer.onError(NSError(domain: urlString, code: NSURLErrorBadURL, userInfo: nil))
                    return Disposables.create()
                }
                var aRequest = URLRequest(url: url)
                aRequest.httpMethod = method.rawValue
                aRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                headerRequest?.forEach { aRequest.setValue($1, forHTTPHeaderField: $0) }
                if let bodyParams = bodyParams {
                    let bodyData = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
                    aRequest.httpBody = bodyData
                }
                
                let task = URLSession.shared.dataTask(with: aRequest) { data, response, error in
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        observer.onError(Error.invalidResponse(response))
                        return 
                    }
                    guard let validData = data else {
                        observer.onError(Error.invalidData)
                        return
                    }
                    observer.onNext(validData)
                    observer.onCompleted()
                }
                task.resume()
                
                return Disposables.create {
                    task.cancel()
                }
            } catch let error {
                observer.onError(error)
            }
            return Disposables.create()
        }).retry { (error: Observable<Error>) -> Observable<Bool> in
            return error.flatMap({ error -> Observable<Bool> in
                return Observable.error(error)
            })
        }
    }
    
}
