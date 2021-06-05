//
//  SearchMoviesViewController.swift
//  Movies
//
//  Created by Muhammad Nizar on 03/06/21.
//

import UIKit
import RxSwift
import SkeletonView

class SearchMoviesViewController: UIViewController {
    
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTextfield: UITextField!
    
    var viewModel = SearchMoviesViewModel()
    var disposeBag = DisposeBag()
    var optionSearchBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        bindViewModel()
    }
    
    private func setupUI() {
        self.navigationController?.navigationBar.tintColor = Constants.Colors.D90016.color()
        self.title = "Search"
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = Constants.Colors.F3F3F3.color().cgColor
        searchView.layer.cornerRadius = 10
        searchView.layer.applySketchShadow(color: Constants.Colors.C4C4C4.color(),
                                           alpha: 1.0,
                                           x: 0,
                                           y: 1,
                                           blur: 4,
                                           spread: 0)
        searchTextfield.returnKeyType = .search
        searchTextfield.placeholder = viewModel.currentType == .movie ? "Search movies" : "Search TV Show"
        
        var menuItems: [UIAction] {
            return [
                UIAction(title: "Movie", image: UIImage(systemName: "ticket"), handler: { (_) in
                    self.updateSelectedSearch(.movie)
                }),
                UIAction(title: "TV Show", image: UIImage(systemName: "tv"), handler: { (_) in
                    self.updateSelectedSearch(.tvShow)
                })
            ]
        }
        var searchMenu: UIMenu {
            return UIMenu(title: "Change Search", image: nil, identifier: nil, options: [], children: menuItems)
        }
        let image = viewModel.currentType == .movie ? UIImage(systemName: "ticket") : UIImage(systemName: "tv")
        optionSearchBarButtonItem = UIBarButtonItem(title: "", image: image, primaryAction: nil, menu: searchMenu)
        navigationItem.rightBarButtonItem = optionSearchBarButtonItem

    }
    
    private func setupTableView() {
        
        for cellType in SearchMoviesCellType.allCases {
            let nibToRegister = UINib(nibName: String(describing: cellType.cellIdentifier()), bundle: Bundle.main)
            tableView.register(nibToRegister, forCellReuseIdentifier: String(describing: cellType.cellIdentifier()))
        }
        let emptyNib = UINib(nibName: String(describing: EmptyTableViewCell.self), bundle: Bundle.main)
        tableView.register(emptyNib, forCellReuseIdentifier: String(describing: EmptyTableViewCell.self))
        
        let loadingNib = UINib(nibName: String(describing: LoadingTableViewCell.self), bundle: Bundle.main)
        tableView.register(loadingNib, forCellReuseIdentifier: String(describing: LoadingTableViewCell.self))
    }
    
    private func bindViewModel() {
        
        viewModel.query.debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asObservable()
            .subscribe(onNext: { [weak self] (searchText) in
                if let querySearch = searchText, querySearch.count > 2 {
                    self?.viewModel.clearAllFetchedData()
                    self?.viewModel.getSearchMovies(true)
                }
            }).disposed(by: disposeBag)
        
        viewModel.dataSourceObservable
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    weakSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.loadingState.asObservable()
            .subscribe(onNext: { [weak self] (loadingState) in
                guard let weakSelf = self else { return }
                DispatchQueue.main.async {
                    if (loadingState == .loading || loadingState == .notLoad) {
                        weakSelf.tableView.showAnimatedSkeleton()
                    } else {
                        weakSelf.tableView.hideSkeleton()
                        weakSelf.tableView.reloadData()
                    }
                }
            })
            .disposed(by: disposeBag)
        
        searchTextfield.text = "marvel"
        viewModel.query.accept(searchTextfield.text)
    }
    
    private func updateSelectedSearch(_ type:SearchType) {
        if (viewModel.currentType == type) {
            return
        }
        
        viewModel.currentType = type
        searchTextfield.text = ""
        viewModel.query.accept("")
        viewModel.clearAllFetchedData()
        searchTextfield.placeholder = viewModel.currentType == .movie ? "Search movies" : "Search TV Show"
        let image = viewModel.currentType == .movie ? UIImage(systemName: "ticket") : UIImage(systemName: "tv")
        optionSearchBarButtonItem.image = image
    }
    
    private func loadMore() {
        if viewModel.loadingState.value != .loading {
            viewModel.getSearchMovies(isBottomLoad: true)
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SearchMoviesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = viewModel.numberOfCellModels()
        if (numberOfRows == 0) {
            numberOfRows = 1
        } else {
            if (viewModel.canLoadMore) {
                numberOfRows = numberOfRows + 1
            }
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfRows = viewModel.numberOfCellModels()
        if (numberOfRows == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EmptyTableViewCell.self), for: indexPath) as! EmptyTableViewCell
            cell.delegate = self
            if (searchTextfield.text?.isEmpty == true) {
                let wording = viewModel.currentType == .movie ? "Search all movies" : "Search all TV Shows"
                cell.configureCell(wording, imageName: "launchScreenIcon")
                cell.retryButton.isHidden = true
            } else {
                cell.configureCell("No Results. Try a new search", imageName: "noResult")
            }
            return cell
        } else {
            if viewModel.isNormalCellForIndex(indexPath) == false {
                loadMore()
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingTableViewCell.self), for: indexPath) as! LoadingTableViewCell
                cell.loadingIndicatorView.startAnimating()
                return cell
            }
            if let cellModel = viewModel.cellModelAtIndex(indexPath.row) {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellType.cellIdentifier()) as! MovieTableViewCell
                cell.configureWithCellModel(cellModel)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (viewModel.numberOfCellModels() == 0 && viewModel.isLoading() == false) { 
            return tableView.frame.height
        }
        return viewModel.heightForCellAtIndex(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (viewModel.numberOfCellModels() == 0 && viewModel.isLoading() == false) {
            return tableView.frame.height
        }
        return viewModel.heightForCellAtIndex(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

// MARK: SkeletonTableViewDataSource
extension SearchMoviesViewController: SkeletonTableViewDataSource {
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return SearchMoviesCellType.Movie.cellIdentifier()
    }
}

// MARK: UITextFieldDelegate
extension SearchMoviesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            var updatedText = text.replacingCharacters(in: textRange, with: string)
            updatedText = updatedText.trimmingCharacters(in: .whitespaces)
            viewModel.query.accept(updatedText)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.query.accept("")
        viewModel.clearAllFetchedData()
        
        return true
    }
    
}

// MARK: EmptyTableViewCellDelegate
extension SearchMoviesViewController: EmptyTableViewCellDelegate {
    func retryButtonDidClicked() {
        self.viewModel.getSearchMovies(true)
    }
}

