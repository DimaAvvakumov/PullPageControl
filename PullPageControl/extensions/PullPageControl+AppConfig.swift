//
//  PullPageControl+AppConfig.swift
//  PullPageControl
//
//  Created by Dmitry Avvakumov on 17.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import Foundation
import UIKit

extension PullPageControl {
    
    class func standart(scrollView:UIScrollView) -> PullPageControl {
        let control = PullPageControl(scrollView: scrollView)
        
        // refresh
        let refreshView = ProgressCircleView(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        control.refreshView = refreshView
        
        // infinity
        let infinityView = ProgressCircleView(frame: CGRect(x: 0.0, y: 0.0, width: 32.0, height: 32.0))
        control.infinityView = infinityView
        
        return control
    }
    
}

extension ProgressCircleView: PullPageRefreshViewProtocol {
    
    func beginRefreshing() {
        startAnimating()
    }
    
    func endRefreshing() {
        stopAnimating()
    }

}
