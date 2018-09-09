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

enum FeedSceneEvent {
    case share(urlString: String, sourceView: UIView)
}

class FeedViewController: UIViewController {
    
    let events: Observable<FeedSceneEvent>
    let disposeBag = DisposeBag()

    private let searchBar = UISearchBar()
    private var searchBarShouldBeginEditing = true
    private lazy var feedDataSource = CollectionViewDataSource<GIF, FeedGIFCell>(collectionView: feedView.giftainerCollectionView,
                                                                                 objectsProvider: feedViewModel.gifsProvider)
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let doubleTapGestureRecognizer = UITapGestureRecognizer()
    private let eventsPublishSubject = PublishSubject<FeedSceneEvent>()
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
        events = eventsPublishSubject.asObservable()
        
        super.init(nibName: nil, bundle: nil)
        
        eventsPublishSubject.disposed(by: disposeBag)
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
        setupTap()
        setupDoubleTap()
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
    
    private func setupTap() {
        feedView.giftainerCollectionView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        tapGestureRecognizer.rx.event
            .asDriver()
            .drive(onNext: { [weak self, searchBar] _ in
                if searchBar.isFirstResponder {
                    searchBar.resignFirstResponder()
                } else {
                    self?.updateLayout()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func updateLayout() {
        guard feedView.isPortrait else {
            return
        }
        isLayoutMaximised = !isLayoutMaximised
        let giftainerLayout = GiftainerLayout()
        giftainerLayout.numberOfColumns = isLayoutMaximised ? 1 : 2
        feedView.giftainerCollectionView.setCollectionViewLayout(giftainerLayout, animated: true)
    }
    
    private func setupDoubleTap() {
        feedView.giftainerCollectionView.addGestureRecognizer(doubleTapGestureRecognizer)
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.rx.event
            .asDriver()
            .drive(onNext: { [feedView, feedViewModel, eventsPublishSubject] doubleTapGestureRecognizer in
                let location = doubleTapGestureRecognizer.location(in: doubleTapGestureRecognizer.view)
                guard let indexPath = feedView.giftainerCollectionView.indexPathForItem(at: location),
                    let cell = feedView.giftainerCollectionView.cellForItem(at: indexPath) else {
                    return
                }
                let gif = feedViewModel.gifsProvider.object(at: indexPath)
                eventsPublishSubject.onNext(.share(urlString: gif.mp4URLString, sourceView: cell))
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
        feedGIFCell.id = gif.id
        Observable.concat(gifsCache.image(for: gif), gifsCache.animatedImage(for: gif))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { event in
                guard feedGIFCell.id == gif.id else {
                    return
                }
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
