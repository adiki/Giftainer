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

class FeedViewController: UIViewController {
    
    enum SceneEvent {
        case share(url: URL, sourceView: UIView)
    }
    
    let events: Observable<SceneEvent>
    let disposeBag = DisposeBag()

    private let searchBar = UISearchBar()
    private var searchBarShouldBeginEditing = true
    private lazy var feedDataSource = CollectionViewDataSource<GIF, FeedGIFCell>(collectionView: feedView.giftainerCollectionView,
                                                                                 objectsProvider: feedViewModel.gifsProvider)
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let doubleTapGestureRecognizer = UITapGestureRecognizer()
    private let eventsPublishSubject = PublishSubject<SceneEvent>()
    private let referencesBag = ReferencesBag()
    
    private var feedView: FeedView {
        return view as! FeedView
    }
    
    private let feedViewModel: FeedViewModel
    private let gifsCache: GIFsCache
    private let vibrationPerformer: VibrationPerformer
    
    init(feedViewModel: FeedViewModel,
         gifsCache: GIFsCache,
         vibrationPerformer: VibrationPerformer) {
        self.feedViewModel = feedViewModel
        self.gifsCache = gifsCache
        self.vibrationPerformer = vibrationPerformer
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
        setupTooltip()
        setupNoGIFsLabel()
        setupNoResultsLabel()
        setupActivityIndicator()
        setupCollectionView()
        setupKeyboardNotifications()
        setupApplicationNotifications()
        setupTap()
        setupDoubleTap()
        feedViewModel.didLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if feedView.isLandscape && feedView.giftainerCollectionView.giftainerLayout?.numberOfColumns == 1 {
            feedView.giftainerCollectionView.giftainerLayout?.numberOfColumns = 2
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let numberOfColumns: Int
        if size.isPortrait && feedViewModel.isLayoutMaximised {
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
    
    private func setupTooltip() {
        feedView.tooltipButton.rx.tap
            .bind { [weak self] in
                self?.hideTooltip()
            }
            .disposed(by: disposeBag)
    }
    
    private func hideTooltip() {
        guard feedView.tooltipView.alpha > 0 else {
            return
        }
        UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [feedView] in
            feedView.tooltipView.alpha = 0
            }.startAnimation()
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
        feedView.giftainerCollectionView.giftainerLayout?.numberOfColumns = feedViewModel.isLayoutMaximised ? 1 : 2
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
        hideTooltip()
        feedViewModel.isLayoutMaximised = !feedViewModel.isLayoutMaximised
        let giftainerLayout = GiftainerLayout()
        giftainerLayout.numberOfColumns = feedViewModel.isLayoutMaximised ? 1 : 2
        feedView.giftainerCollectionView.setCollectionViewLayout(giftainerLayout, animated: true)
    }
    
    private func setupDoubleTap() {
        feedView.giftainerCollectionView.addGestureRecognizer(doubleTapGestureRecognizer)
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        doubleTapGestureRecognizer.rx.event
            .asDriver()
            .drive(onNext: { [weak self] doubleTapGestureRecognizer in
                self?.hideTooltip()
                self?.share(with: doubleTapGestureRecognizer)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default
            .addObserver { [weak self] (notification: KeyboardWillShowNotification) in
                self?.updateGiftainerCollectionViewBottomConstraint(keyboardNotification: notification)
            }
            .disposed(by: referencesBag)
        
        NotificationCenter.default
            .addObserver { [weak self] (notification: KeyboardWillHideNotification) in
                self?.updateGiftainerCollectionViewBottomConstraint(keyboardNotification: notification)
            }
            .disposed(by: referencesBag)
    }
    
    private func updateGiftainerCollectionViewBottomConstraint(keyboardNotification: KeyboardNotification) {
        let collectionViewBottomConstraint = feedView.giftainerCollectionView.constraint(for: feedView.giftainerCollectionView.bottomAnchor,
                                                                                         and: feedView.bottomAnchor)
        collectionViewBottomConstraint?.constant = -keyboardNotification.endFrame.height
        UIViewPropertyAnimator(duration: keyboardNotification.duration,
                               curve: keyboardNotification.animationOptions.curve) { [feedView] in
                feedView.layoutIfNeeded()
            }
            .startAnimation()
    }
    
    private func setupApplicationNotifications() {
        NotificationCenter.default
            .addObserver { [feedViewModel] (notification: ApplicationWillEnterForegroundNotification) in
                feedViewModel.willEnterForeground()
            }
            .disposed(by: referencesBag)
    }
    
    private func configure(feedGIFCell: FeedGIFCell, gif: GIF) {
        feedGIFCell.id = gif.id
        
        configurePanGestureRecognizer(for: feedGIFCell, gif: gif)
        configureRefreshButton(for: feedGIFCell, gif: gif)
        fetchImage(for: feedGIFCell, gif: gif)
    }
    
    private func configurePanGestureRecognizer(for feedGIFCell: FeedGIFCell, gif: GIF) {
        var didVibrate = false
        var didOpenShare = false
        feedGIFCell.panGestureRecognizer.rx.event
            .subscribe(onNext: { [weak self, feedView, feedViewModel, vibrationPerformer] panGestureRecognizer in
                guard feedView.isPortrait && feedViewModel.isLayoutMaximised else {
                    return
                }
                let translationX = panGestureRecognizer.translation(in: nil).x
                let progress = min(abs(translationX) / (feedView.frame.width / 2), 1)
                switch panGestureRecognizer.state {
                case .began:
                    didVibrate = false
                    didOpenShare = false
                    self?.hideTooltip()
                case .changed:
                    guard !didOpenShare else {
                        return
                    }
                    feedGIFCell.set(imageViewDeltaConstant: translationX)
                    if translationX < 0 {
                        feedGIFCell.imageView.alpha = 1 - progress
                        if !didVibrate && progress > 0.5 {
                            didVibrate = true
                            vibrationPerformer.vibrate()
                        }
                    } else if translationX > 0 && progress > 0.3 {
                        didOpenShare = true
                        vibrationPerformer.vibrate()
                        self?.share(with: panGestureRecognizer)
                    }
                case .ended, .cancelled, .failed:
                    let velocityX = panGestureRecognizer.velocity(in: nil).x
                    let imageViewAlpha: CGFloat
                    if translationX < 0 {
                        let completed = progress > 0.5 || velocityX < -500                                                
                        if !didVibrate && completed {
                            didVibrate = true
                            vibrationPerformer.vibrate()
                        }
                        if completed {
                            feedViewModel.hide(gif: gif)
                        }
                        imageViewAlpha = completed ? 0 : 1
                        feedGIFCell.set(imageViewDeltaConstant: completed ? -feedView.frame.width : 0)
                    } else {
                        imageViewAlpha = 1
                        feedGIFCell.set(imageViewDeltaConstant: 0)
                    }
                    UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                        feedGIFCell.imageView.alpha = imageViewAlpha
                        feedGIFCell.layoutIfNeeded()
                        }.startAnimation()
                default:
                    break
                }
            })
            .disposed(by: feedGIFCell.disposeBag)
    }
    
    private func configureRefreshButton(for feedGIFCell: FeedGIFCell, gif: GIF) {
        feedGIFCell.refreshButton.rx.tap
            .bind { [weak self] in
                self?.fetchImage(for: feedGIFCell, gif: gif)
            }
            .disposed(by: feedGIFCell.disposeBag)
    }
    
    private func fetchImage(for feedGIFCell: FeedGIFCell, gif: GIF) {
        feedGIFCell.activityIndicatorView.startAnimating()
        feedGIFCell.refreshButton.isHidden = true        
        Observable.concat(gifsCache.image(for: gif),
                          gifsCache.animatedImage(for: gif))
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
            }, onError: { error in
                guard feedGIFCell.id == gif.id else {
                    return
                }
                feedGIFCell.progressView.isHidden = true
                feedGIFCell.activityIndicatorView.stopAnimating()
                feedGIFCell.refreshButton.isHidden = false
            })
            .disposed(by: feedGIFCell.disposeBag)
    }
    
    private func share(with gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.location(in: feedView.giftainerCollectionView)
        guard let indexPath = feedView.giftainerCollectionView.indexPathForItem(at: location),
            let cell = feedView.giftainerCollectionView.cellForItem(at: indexPath) else {
                return
        }
        let gif = feedViewModel.gifsProvider.object(at: indexPath)
        eventsPublishSubject.onNext(.share(url: gif.localMP4URL, sourceView: cell))
    }
}

extension FeedViewController: GiftainerLayoutDelegate {
        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        showTooltipsIfNeeded()
    }
    
    private func showTooltipsIfNeeded() {
        guard feedViewModel.gifsProvider.numberOfObjects() > 0 else {
            return
        }
        let showTooltip = { [feedView] in
            UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                feedView.tooltipView.alpha = 1
                }.startAnimation()
        }
        if feedViewModel.isLayoutMaximised && !feedViewModel.wasTapTooltipPresented {
            feedViewModel.wasTapTooltipPresented = true
        } else if feedView.isPortrait && !feedViewModel.isLayoutMaximised && !feedViewModel.wasTapTooltipPresented {
            feedViewModel.wasTapTooltipPresented = true
            feedView.tooltipLabel.text = "\(String.Single_tap_maximises_layout)\n\(String.Double_tap_shares_gif)"
            showTooltip()
        } else if feedView.isPortrait && feedViewModel.isLayoutMaximised && !feedViewModel.wasSwipeTooltipPresented {
            feedViewModel.wasSwipeTooltipPresented = true
            feedView.tooltipLabel.text = "\(String.Swipe_right_shares_gif)\n\(String.Swipe_left_deletes_gif)\n\(String.Single_tap_minimises_layout)"
            showTooltip()
        }
    }
    
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
        guard searchBarShouldBeginEditing else {
            return false
        }
        if feedViewModel.gifsProvider.numberOfObjects() > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            feedView.giftainerCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        return true
    }
    
    // It is a workaround to prevent the odd animation of the carriage presentation
    // when searchBar is becoming first responder for the first time
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        guard searchBar.tintColor == .white else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.searchBar.tintColor = .snapperRocksBlue
        }
    }
    
    // This method is called before searchBarShouldBeginEditing, when cancel button is tapped.
    // Storing searchBarShouldBeginEditing prevents keyboard presentation when cancel button is tapped
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBarShouldBeginEditing = searchBar.isFirstResponder
    }
}
