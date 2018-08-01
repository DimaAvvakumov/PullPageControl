//
//  PullPageControl.swift
//  PullPageControl
//
//  Created by Dmitry Avvakumov on 17.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// MARK: UIView

public protocol PullPageRefreshViewProtocol {
    
    func beginRefreshing()
    func endRefreshing()
    
    func setProgress(_ progress: CGFloat, animated: Bool)
    
}

// MARK: Pull Control
open class PullPageControl {
    
    typealias PullPageRefreshView = PullPageRefreshViewProtocol & UIView
    
    // State
    public enum State {
        case normal(isNext:Bool)
        case refreshing
        case loadingPage
        
        func isRefreshAvailable() -> Bool {
            switch self {
            case .refreshing:
                return false
            default:
                return true
            }
        }
        
        func isNextAvailable() -> Bool {
            switch self {
            case .normal(let isNext):
                return isNext
            default:
                return false
            }
        }
    }

    // Cfg
    public struct Config {
        // Pull To Refresh
        let refreshTriggerOffset: CGFloat = 88.0
        let refreshControlY: CGFloat = 28.0
        
        let baseInset: CGFloat = 0.0
        let refreshInset: CGFloat = 0.0
        var refreshInsetCompile: CGFloat {
            return (refreshInset > 0) ? refreshInset : refreshTriggerOffset
        }
        
        // Infinity Scroll
        let infinityTriggerOffset: CGFloat = 200.0
        let infinityBaseInset: CGFloat = 0.0
        let infinityInset: CGFloat = 88.0
        let infinityControlY: CGFloat = 28.0
    }
    
    // Private
    let bag = DisposeBag()
    var baseTopInset: CGFloat = 0.0
    var baseBottomInset: CGFloat = 0.0
    var infinityWaitUserInteraction: Bool = true
    
    // Public
    public let state = BehaviorRelay<State>(value: .normal(isNext: false) )
    public var config = Config()
    
    // Outlets
    public let scrollView: UIScrollView
    public var refreshView: PullPageRefreshViewProtocol?
    public var infinityView: PullPageRefreshViewProtocol?
    
    // Events
    public let refreshEvent = PublishSubject<Bool>()
    public let nextPageEvent = PublishSubject<Bool>()
    
    // Init
    public init(scrollView view: UIScrollView) {
        scrollView = view
    }
    
    // Methods
    public func setup() {
        // refresh view
        if let view = refreshView as? PullPageRefreshView {
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
        }
        
        // infinity view
        if let view = infinityView as? PullPageRefreshView {
            view.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(view)
        }
        
        // content offset
        scrollView.rx.contentOffset.asObservable().subscribe(onNext: { [weak self] (point) in
            self?.handleOffset( point )
            self?.handleRefreshControlOffset( point )
            self?.handleInfinityControlOffset( point )
        }).disposed(by: bag)
        scrollView.rx.willEndDragging.asObservable().subscribe(onNext: { [weak self] (event) in
            self?.handleEndDragging()
        }).disposed(by: bag)
        
        // subscribe to state
        state.asObservable().subscribe(onNext: { [weak self] (state) in
            self?.updateState( state )
        }).disposed(by: bag)
    }
    
    // Private
    func handleOffset(_ point: CGPoint) {
        handleOffsetForRefresh()
        handleOffsetForInfinity()
    }
    
    func handleOffsetForRefresh() {
        if !state.value.isRefreshAvailable() {
            return
        }
        
        let offset = scrollContentOffsetY()
        if offset < 0 {
            return
        }
        
        let refreshTriggerOffset = config.refreshTriggerOffset
        if let refreshView = self.refreshView {
            var progress = offset / refreshTriggerOffset
            if progress > 1.0 {
                progress = 1.0
            }
            
            refreshView.setProgress(progress, animated: false)
        }
    }
    
    func handleOffsetForInfinity() {
        if !state.value.isNextAvailable() {
            return
        }
        
        let screenSize = scrollView.bounds.size.height
        let contentSize = scrollView.contentSize.height
        if screenSize > contentSize {
            return
        }
        
        if scrollView.isDragging {
            infinityWaitUserInteraction = false
        }
        
        if infinityWaitUserInteraction {
            return
        }
        
        let delta = contentSize - screenSize - scrollView.contentOffset.y
        if delta < config.infinityTriggerOffset {
            
            nextPageEvent.onNext(true)
        }
    }
    
    func handleRefreshControlOffset(_ panPoint: CGPoint) {
        guard let view = refreshView as? PullPageRefreshView else {
            return
        }
        
        var frame = view.frame
        frame.origin.x = CGFloat( round((scrollView.bounds.size.width - frame.size.width) / 2.0) )
        frame.origin.y = -frame.size.height - config.refreshControlY
        view.frame = frame
    }
    
    func handleInfinityControlOffset(_ panPoint: CGPoint) {
        guard let view = infinityView as? PullPageRefreshView else {
            return
        }
        
        var frame = view.frame
        frame.origin.x = CGFloat( round((scrollView.bounds.size.width - frame.size.width) / 2.0) )
        frame.origin.y = scrollView.contentSize.height + config.infinityControlY
        view.frame = frame
    }
    
    func handleEndDragging() {
        if !state.value.isRefreshAvailable() {
            return
        }
        
        let offset = scrollContentOffsetY()
        if offset < 0 {
            return
        }
        
        let refreshTriggerOffset = config.refreshTriggerOffset
        
        if offset < refreshTriggerOffset {
            return
        }
        
        // TODO:- Add check for time event
        refreshEvent.onNext(true)
    }
    
    func updateState(_ state: State) {
        var inset = scrollView.contentInset
        var infinityAlpha:CGFloat = 0.0
        
        // default
        inset.top = config.baseInset
        inset.bottom = config.infinityBaseInset
        
        // check state
        switch state {
        case .refreshing:
            inset.top = config.refreshInsetCompile
            refreshView?.beginRefreshing()
        case .loadingPage:
            inset.bottom = config.infinityInset
            infinityAlpha = 1.0
            infinityView?.beginRefreshing()
            
            infinityWaitUserInteraction = true
        default:
            refreshView?.endRefreshing()
            infinityView?.endRefreshing()
        }
        
        // animaiton
        let animBlock: () -> Void = { [weak self] in
            // update constraints
            self?.scrollView.contentInset = inset
            if let view = self?.infinityView as? PullPageRefreshView {
                view.alpha = infinityAlpha
            }
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.beginFromCurrentState], animations: animBlock, completion: nil)
    }
    
    private func scrollContentOffsetY() -> CGFloat {
        var inset = scrollView.contentInset.top
        if #available(iOS 11.0, *) {
            inset += scrollView.adjustedContentInset.top
        }
        return -scrollView.contentOffset.y - inset
    }
    
}
