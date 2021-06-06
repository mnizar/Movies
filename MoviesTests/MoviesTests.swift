//
//  MoviesTests.swift
//  MoviesTests
//
//  Created by Muhammad Nizar on 03/06/21.
//

import XCTest
@testable import Movies

class MoviesTests: XCTestCase {
    
    var sut: SearchMoviesViewModel!

    override func setUpWithError() throws {
      try super.setUpWithError()
      sut = SearchMoviesViewModel()
    }

    override func tearDownWithError() throws {
      sut = nil
      try super.tearDownWithError()
    }

    func testAddContentCellModels() {
        let searchModel1 = SearchModel()
        searchModel1.imdbID = "tt4154664"
        searchModel1.year = "2019"
        searchModel1.title = "Captain Marvel"
        searchModel1.type = "movie"
        searchModel1.posterUrl = "https://m.media-amazon.com/images/M/MV5BMTE0YWFmOTMtYTU2ZS00ZTIxLWE3OTEtYTNiYzBkZjViZThiXkEyXkFqcGdeQXVyODMzMzQ4OTI@._V1_SX300.jpg"
        
        let searchModel2 = SearchModel()
        searchModel2.imdbID = "tt3067038"
        searchModel2.year = "2013"
        searchModel2.title = "Marvel One-Shot: Agent Carter"
        searchModel2.type = "movie"
        searchModel2.posterUrl = "https://m.media-amazon.com/images/M/MV5BZDIwZTM4M2QtMWFhYy00N2VmLWFlMjItMzI3NjBjYTc0OTMxXkEyXkFqcGdeQXVyNTE1NjY5Mg@@._V1_SX300.jpg"
        
        let searchModel3 = SearchModel()
        searchModel3.imdbID = "tt3438640"
        searchModel3.year = "2014"
        searchModel3.title = "Marvel One-Shot: All Hail the King"
        searchModel3.type = "movie"
        searchModel3.posterUrl = "https://m.media-amazon.com/images/M/MV5BZGFkMTZkMDQtNzM4Yy00YWEwLTkzOWEtZTMyNDRlNmJhYWJhXkEyXkFqcGdeQXVyNTE1NjY5Mg@@._V1_SX300.jpg"
        
        let models = [searchModel1, searchModel2, searchModel3]
        sut.buildContentCellModels(models)
        
        XCTAssertTrue(sut.dataSource?.count == 3)
        XCTAssertTrue(sut.numberOfCellModels() == 3)
    }
    
    func testSaveToDB() {
        let searchModel1 = SearchModel()
        searchModel1.imdbID = "tt4154664"
        searchModel1.year = "2019"
        searchModel1.title = "Captain Marvel"
        searchModel1.type = "movie"
        searchModel1.posterUrl = "https://m.media-amazon.com/images/M/MV5BMTE0YWFmOTMtYTU2ZS00ZTIxLWE3OTEtYTNiYzBkZjViZThiXkEyXkFqcGdeQXVyODMzMzQ4OTI@._V1_SX300.jpg"
        
        let searchModel2 = SearchModel()
        searchModel2.imdbID = "tt3067038"
        searchModel2.year = "2013"
        searchModel2.title = "Marvel One-Shot: Agent Carter"
        searchModel2.type = "movie"
        searchModel2.posterUrl = "https://m.media-amazon.com/images/M/MV5BZDIwZTM4M2QtMWFhYy00N2VmLWFlMjItMzI3NjBjYTc0OTMxXkEyXkFqcGdeQXVyNTE1NjY5Mg@@._V1_SX300.jpg"
        
        let searchModel3 = SearchModel()
        searchModel3.imdbID = "tt3438640"
        searchModel3.year = "2014"
        searchModel3.title = "Marvel One-Shot: All Hail the King"
        searchModel3.type = "movie"
        searchModel3.posterUrl = "https://m.media-amazon.com/images/M/MV5BZGFkMTZkMDQtNzM4Yy00YWEwLTkzOWEtZTMyNDRlNmJhYWJhXkEyXkFqcGdeQXVyNTE1NjY5Mg@@._V1_SX300.jpg"
        
        let models = [searchModel1, searchModel2, searchModel3]
        let keyword = "marvel"
        let type:SearchType = .movie
        sut.saveItems(keyword: keyword, type: type, page: 1, items: models)
        
        let fetchSearchResult = sut.fetchSearchResultFromDb(keyword: keyword, type: type)
        XCTAssertTrue(fetchSearchResult != nil)
        XCTAssertEqual(fetchSearchResult?.keyword, keyword, "keyword must be marvel")
        
        let fetchItems = sut.fetchSearchModelFromDb(keyword: keyword, type: type)
        XCTAssertEqual(fetchItems?.count, 3, "total items must be 3")
    }
}
