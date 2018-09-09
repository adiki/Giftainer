//
//  FeedViewController.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

//TODO make transitions reactive
class FeedViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    private let searchBar = UISearchBar()
    private var searchBarShouldBeginEditing = true
    private lazy var feedDataSource = CollectionViewDataSource<GIF, FeedGIFCell>(collectionView: feedView.giftainerCollectionView,
                                                                                 objectsProvider: feedViewModel.gifsProvider)
    private let referencesBag = ReferencesBag()
    
    private var feedView: FeedView {
        return view as! FeedView
    }
    
    private let feedViewModel: FeedViewModel
    private let gifsCache: GIFsCache
    
    private var isLayoutMaximised = false
    
    init(feedViewModel: FeedViewModel,
         gifsCache: GIFsCache) {
        self.feedViewModel = feedViewModel
        self.gifsCache = gifsCache
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = FeedView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupNoGIFsLabel()
        setupNoResultsLabel()
        setupActivityIndicator()
        setupCollectionView()
        setupKeyboardNotifications()
        setupClosingKeyboardOnTap()
        feedViewModel.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let numberOfColumns: Int
        if feedView.isPortrait && isLayoutMaximised {
            numberOfColumns = 1
        } else {
            numberOfColumns = 2
        }
        feedView.giftainerCollectionView.giftainerLayout?.numberOfColumns = numberOfColumns
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = .Search
        searchBar.tintColor = .white
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        feedViewModel.accept(searchInput: searchBar.rx.text.orEmpty)
        feedViewModel.searchText
            .bind(to: searchBar.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupNoGIFsLabel() {
        feedViewModel.isNoGIFsInfoHidden
            .observeOn(MainScheduler.instance)
            .bind(to: feedView.noGIFsLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setupNoResultsLabel() {
        feedViewModel.isNoResultsInfoHidden
            .observeOn(MainScheduler.instance)
            .bind(to: feedView.noResultsFoundLabel.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func setupActivityIndicator() {
        feedViewModel.isActivityInProgress
            .observeOn(MainScheduler.instance)
            .bind(to: feedView.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        feedView.giftainerCollectionView.delegate = self
        feedView.giftainerCollectionView.dataSource = feedDataSource
        feedView.giftainerCollectionView.contentInset.bottom = 15
        feedDataSource.cellForConfiguration
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] feedGIFCell, gif in
                self?.configure(feedGIFCell: feedGIFCell, gif: gif)
            })
            .disposed(by: disposeBag)        
    }
    
    private func setupClosingKeyboardOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        feedView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.rx.event
            .asDriver()
            .drive(onNext: { [searchBar] _ in
                searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default
            .addObserver { [feedView] (notification: KeyboardWillShowNotification) in
                feedView.giftainerCollectionView.constraint(for: feedView.giftainerCollectionView.bottomAnchor, and: feedView.bottomAnchor)?.constant = -notification.endFrame.height
                UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                    feedView.layoutIfNeeded()
                }).startAnimation()
            }
            .disposed(by: referencesBag)
        
        NotificationCenter.default
            .addObserver { [feedView] (notification: KeyboardWillHideNotification) in
                feedView.giftainerCollectionView.constraint(for: feedView.giftainerCollectionView.bottomAnchor, and: feedView.bottomAnchor)?.constant = 0
                UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                    feedView.layoutIfNeeded()
                }).startAnimation()
            }
            .disposed(by: referencesBag)
    }
    
    private func configure(feedGIFCell: FeedGIFCell, gif: GIF) {
        feedGIFCell.contentView.backgroundColor = gif.id.color
        Observable.concat(gifsCache.image(for: gif), gifsCache.animatedImage(for: gif))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                switch event {
                case .progress(let progress):
                    feedGIFCell.progressView.isHidden = false
                    feedGIFCell.progressView.setProgress(progress, animated: true)
                    if progress == 1 {
                        feedGIFCell.progressView.isHidden = true
                        feedGIFCell.activityIndicatorView.stopAnimating()
                    }
                case .image(let image):
                    feedGIFCell.imageView.image = image.makePendulum()
                    if image.images != nil {
                        feedGIFCell.progressView.isHidden = true
                        feedGIFCell.activityIndicatorView.stopAnimating()
                    }
                }
            })
            .disposed(by: feedGIFCell.disposeBag)
    }
}

extension FeedViewController: GiftainerLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        let gif = feedViewModel.gifsProvider.object(at: indexPath)
        return CGSize(width: gif.width, height: gif.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard feedView.isPortrait else {
            return
        }
        isLayoutMaximised = !isLayoutMaximised
        let giftainerLayout = GiftainerLayout()
        giftainerLayout.numberOfColumns = isLayoutMaximised ? 1 : 2
        feedView.giftainerCollectionView.setCollectionViewLayout(giftainerLayout, animated: true)
    }
}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        defer {
            searchBarShouldBeginEditing = true
        }
        if searchBarShouldBeginEditing {
            if feedViewModel.gifsProvider.numberOfObjects() > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                feedView.giftainerCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
        return searchBarShouldBeginEditing
    }
    
    //It is a workaround to prevent the odd animation of the carriage presentation on iOS11 when searchBar is becoming first responder for the first time
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard searchBar.tintColor == .white else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.searchBar.tintColor = .snapperRocksBlue
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarShouldBeginEditing = searchBar.isFirstResponder
    }
}

extension FeedViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return searchBar.isFirstResponder
    }
}
