//
//  SearchMoviesViewModel.swift
//  Movies
//
//  Created by Muhammad Nizar on 03/06/21.
//

import Foundation
import RxSwift
import RxCocoa


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
    var errorMessage:String = ""
    var cellModels = [SearchMoviesContentCellModel]()
    var page = 1
    var canLoadMore = true
    
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
        return self.loadingState.value == .loading ||
            self.loadingState.value == .notLoad
    }
}

// MARK: Request API
extension SearchMoviesViewModel {
    func getSearchMovies(_ clearCurrentData: Bool = false, isBottomLoad: Bool = false) {
        if isBottomLoad == false {
            page = 1
            self.loadingState.accept(.loading)
        }
        
        return SearchProvider()
            .fetchSearch(keyword: query.value ?? "", type: currentType, page: page)
            .catch({ error -> Observable<SearchResponseModel?> in
                print("SearchProvider fetchSearch :\(error)")
                return Observable.just(nil)
            })
            .subscribe(onNext: { [weak self] responseModel in
                guard let weakSelf = self else { return }
                
                if clearCurrentData {
                    weakSelf.clearAllFetchedData()
                }
                
                
                if let validResponseModel = responseModel, let response = validResponseModel.response?.lowercased() {
                    if response == "true", let searchArray = validResponseModel.search, searchArray.count > 0  {
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
