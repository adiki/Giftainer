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
    private lazy var feedDataSource = CollectionViewDataSource<GIF, FeedGIFCell>(collectionView: feedView.giftainerCollectionView,
                                                                                 objectsProvider: feedViewModel.gifsProvider)
    private let tokensBag = TokensBag()
    
    private var feedView: FeedView {
        return view as! FeedView
    }
    
    private let feedViewModel: FeedViewModel
    
    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
        
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
        setupMaximisationUpdate()
        setupKeyboardNotifications()
        setupClosingKeyboardOnTap()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        feedViewModel.viewDidLayoutSubviews()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        feedViewModel.viewWillTransition()
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
    
    private func setupMaximisationUpdate() {
        feedViewModel.isMaximised
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [feedView] isMaximised in
                let giftainerLayout = GiftainerLayout()
                if isMaximised {
                    giftainerLayout.numberOfColumns = feedView.frame.size.maximizedNumberOfColumns                    
                } else {
                    giftainerLayout.numberOfColumns = feedView.frame.size.mimizedNumberOfColumns
                }
                feedView.giftainerCollectionView.setCollectionViewLayout(giftainerLayout, animated: true)
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
            .addObserver { [weak self] (notification: KeyboardWillShowNotification) in
                self?.feedView.giftainerCollectionViewBottomConstraint?.constant = -notification.endFrame.height
                UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                    self?.feedView.layoutIfNeeded()
                }).startAnimation()
            }
            .disposed(by: tokensBag)
        
        NotificationCenter.default
            .addObserver { [weak self] (notification: KeyboardWillHideNotification) in
                self?.feedView.giftainerCollectionViewBottomConstraint?.constant = 0
                UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                    self?.feedView.layoutIfNeeded()
                }).startAnimation()
            }
            .disposed(by: tokensBag)
    }
    
    private func configure(feedGIFCell: FeedGIFCell, gif: GIF) {
        feedGIFCell.contentView.backgroundColor = gif.id.color
    }
}

extension FeedViewController: GiftainerLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, sizeAtIndexPath indexPath: IndexPath) -> CGSize {
        let gif = feedViewModel.gifsProvider.object(at: indexPath)
        return CGSize(width: gif.width, height: gif.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedViewModel.didTapOnObject()
    }
}

extension FeedViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if feedViewModel.gifsProvider.numberOfObjects() > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            feedView.giftainerCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }        
        return true
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
}

extension FeedViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return searchBar.isFirstResponder
    }
}
