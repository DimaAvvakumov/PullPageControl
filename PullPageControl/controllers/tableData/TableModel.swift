//
//  TableModel.swift
//  PullPageControl
//
//  Created by Avvakumov Dmitry on 15.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import Foundation

class TableModel: TableRow {
    typealias Identity = String
    
    var itemId: Int = 0
    var title: String = ""
    
    init(itemId initId: Int, title initTitle: String) {
        itemId = initId
        title = initTitle
        
        super.init()
    }
    
    override var cellIdentifier: String {
        return "TableModelCell"
    }
    
    override var identity: String {
        return "\(itemId)"
    }
    
    override func equalTo(other: TableRow) -> Bool {
        if let rhs = other as? TableModel {
            let lhs = self
            if lhs.itemId != rhs.itemId { return false }
            if lhs.title != rhs.title { return false }
            
            return true
        }
        return false
    }

}
