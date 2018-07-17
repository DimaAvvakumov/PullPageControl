//
//  TableRawProtocol.swift
//  paywash
//
//  Created by adBODKAt on 12.04.2018.
//  Copyright © 2018 East Media Ltd. All rights reserved.
//

import Foundation
import UIKit
import Differentiator

protocol TableRawProtocol {
    var cellIdentifier: String { get }
    
    func associatedWithNibLayout() -> Bool
}

protocol AnimatableTableRow: TableRawProtocol, Equatable, IdentifiableType {
    
}

extension TableRawProtocol {
    func associatedWithNibLayout() -> Bool {
        return true
    }
}

class TableRow: Equatable, IdentifiableType, TableRawProtocol {
    typealias Identity = String
    
    var cellIdentifier: String {
        return "Cell"
    }
    
    var identity: String {
        return ""
    }
    
    func equalTo(other: TableRow) -> Bool {
        return true
    }
    
    static func == (lhs: TableRow, rhs: TableRow) -> Bool {
        return lhs.equalTo(other: rhs)
    }
    
}

extension UITableView {
    
    func dequeueReusableCellWithRaw(_ raw:TableRawProtocol, indexPath:IndexPath) -> UITableViewCell {
        
        let reuseId = raw.cellIdentifier
        
        if let cell = dequeueReusableCell(withIdentifier: reuseId) {
            return cell
        }
        if raw.associatedWithNibLayout() {
            register(UINib.init(nibName: reuseId, bundle: nil), forCellReuseIdentifier: reuseId)
        } else {
            // register(UINib.init(nibName: reuseId, bundle: nil), forCellReuseIdentifier: reuseId)
        }
        
        return dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
    }
    
}
