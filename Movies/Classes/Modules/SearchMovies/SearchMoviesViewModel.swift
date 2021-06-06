//
//  SearchMoviesViewModel.swift
//  Movies
//
//  Created by Muhammad Nizar on 03/06/21.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift

enum SearchMoviesCellType: String, CaseIterable {
    case Movie
    
    func cellIdentifier() -> String {
        return self.rawValue + "TableViewCell"
    }
}

struct SearchMoviesContentCellModel {
    var cellType: SearchMoviesCellType = .Movie
    var data: Any?
}

class SearchMoviesViewModel {
    var disposeBag = DisposeBag()
    var loadingState = BehaviorRelay<LoadingState>(value: .notLoad)
    var query = BehaviorRelay<String?>(value: nil)
    var currentType:SearchType = .movie
    var dataSourceObservable = BehaviorRelay<[SearchMoviesContentCellModel]?>(value: nil)
    var dataSource: [SearchMoviesContentCellModel]? {
        get {
            return dataSourceObservable.value
        }
        set {
            dataSourceObservable.accept(newValue)
        }
    }
    var errorMessage:String? = nil
    var cellModels = [SearchMoviesContentCellModel]()
    var page = 1
    var canLoadMore = true
    private var realm: Realm { return try! Realm() }
    
    func clearAllFetchedData() {
        canLoadMore = true
        dataSource?.removeAll()
        cellModels = []
    }
    
    func buildContentCellModels(_ models: [SearchModel]? = nil) {
        if let validModels = models, validModels.count > 0 {
            for searchModel in validModels {
                cellModels.append(SearchMoviesContentCellModel(cellType: .Movie, data: searchModel))
            }
        }
        dataSource = cellModels
    }
    
    func isLoading() -> Bool {
        return self.loadingState.value == .loading
    }
    
    func performSearch(_ clearCurrentData: Bool = false, isBottomLoad: Bool = false) {
        
        let keyword = query.value ?? ""
        let searchType = currentType
        
        if let searchModels = fetchSearchModelFromDb(keyword: keyword, type: searchType), searchModels.count > 0 {
            buildContentCellModels(searchModels)
            loadingState.accept(.finished)
        }
        getSearchMovies(clearCurrentData, isBottomLoad: isBottomLoad)
    }
}

// MARK: Request API
extension SearchMoviesViewModel {
    func getSearchMovies(_ clearCurrentData: Bool = false, isBottomLoad: Bool = false) {
        if isBottomLoad == false {
            page = 1
            loadingState.accept(.loading)
        }
        
        return SearchProvider()
            .fetchSearch(keyword: query.value ?? "", type: currentType, page: page)
            .catch({  [weak self]  error -> Observable<SearchResponseModel?>  in
                if let response = error as? URLResponse {
                    self?.errorMessage = response.description
                } else {
                    self?.errorMessage = "No Internet Connection"
                }
                self?.canLoadMore = false
                self?.loadingState.accept(.failed)
                return Observable.empty()
            })
            .subscribe(onNext: { [weak self] responseModel in
                guard let weakSelf = self else { return }
                
                weakSelf.errorMessage = nil
                
                if clearCurrentData {
                    weakSelf.clearAllFetchedData()
                }
                
                if let validResponseModel = responseModel, let response = validResponseModel.response?.lowercased() {
                    if response == "true", let searchArray = validResponseModel.search, searchArray.count > 0  {
                        DispatchQueue.main.async {
                            weakSelf.saveItems(keyword: weakSelf.query.value ?? "", type: weakSelf.currentType, page: weakSelf.page, items: searchArray)
                        }
                        weakSelf.buildContentCellModels(searchArray)
                        weakSelf.page = weakSelf.page + 1
                        weakSelf.loadingState.accept(.finished)
                        
                    } else {
                        weakSelf.errorMessage = validResponseModel.error ?? ""
                        weakSelf.canLoadMore = false
                        weakSelf.loadingState.accept(.failed)
                    }
                } else {
                    weakSelf.canLoadMore = false
                    weakSelf.loadingState.accept(.failed)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: DataSource
extension SearchMoviesViewModel {
    
    func numberOfCellModels() -> Int {
        return dataSource?.count ?? 0
    }
    
    func cellModelAtIndex(_ index: Int) -> SearchMoviesContentCellModel? {
        guard index >= 0 && index < numberOfCellModels() else {
            return nil
        }
        return dataSource?.item(at: index)
    }
    
    func heightForCellAtIndex(_ index: Int) -> CGFloat {
        return 110.0
    }
    
    func isNormalCellForIndex(_ indexPath: IndexPath) -> Bool {
        return indexPath.row < numberOfCellModels()
    }
}

// MARK: LocalDB
extension SearchMoviesViewModel {
    
    func saveItems(keyword:String, type:SearchType, page:Int, items:[SearchModel]) {
        if let searchResult = fetchSearchResultFromDb(keyword: keyword, type: type), page > 1 {
            
            try! realm.write {
                // Update some properties on the instance.
                // These changes are saved to the realm
                searchResult.items.append(objectsIn: items)
            }
        } else {
            let searchResult = SearchResult()
            searchResult.keyword = keyword
            searchResult.type = type.rawValue
            searchResult.items.append(objectsIn: items)
            saveItem(searchResult)
        }
    }
    
    func fetchSearchResultFromDb(keyword: String, type:SearchType) -> SearchResult? {
        let obj = realm.objects(SearchResult.self).filter("keyword == %@ AND type == %@", keyword, type.rawValue).first
        return obj
    }
    
    func fetchSearchModelFromDb(keyword: String, type:SearchType) -> [SearchModel]? {
        let objs = realm.objects(SearchResult.self).filter("keyword == %@ AND type == %@", keyword, type.rawValue).first
        if let results = objs?.items {
            return Array(results)
        }
        return nil
    }
    
    func saveItem(_ result: SearchResult?) {
        guard let validResult = result else { return }
        try! realm.write {
            realm.add(validResult, update: .modified)
        }
    }
}
