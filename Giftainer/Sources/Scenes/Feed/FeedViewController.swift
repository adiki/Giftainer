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
    
    private let searchBar = UISearchBar()
    
    private var tokens: [NotificationToken] = []
    
    let disposeBag = DisposeBag()
    
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
        setupClosingKeyboardOnTap()
        setupKeyboardNotifications()
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = .Search
        searchBar.tintColor = .white
        searchBar.delegate = self
        navigationItem.titleView = searchBar
    }
    
    private func setupClosingKeyboardOnTap() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        feedView.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.rx.event
            .asDriver()
            .drive(onNext: { [searchBar] _ in
                searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func setupKeyboardNotifications() {
        tokens.append(NotificationCenter.default.addObserver { [weak self] (notification: KeyboardWillShowNotification) in
            self?.feedView.flowCollectionViewBottomConstraint?.constant = -notification.endFrame.height
            UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                self?.feedView.layoutIfNeeded()
            }).startAnimation()
        })
        
        tokens.append(NotificationCenter.default.addObserver { [weak self] (notification: KeyboardWillHideNotification) in
            self?.feedView.flowCollectionViewBottomConstraint?.constant = 0
            UIViewPropertyAnimator(duration: notification.duration, curve: notification.animationOptions.curve, animations: {
                self?.feedView.layoutIfNeeded()
            }).startAnimation()
        })
    }
}

extension FeedViewController: UISearchBarDelegate {
    
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
