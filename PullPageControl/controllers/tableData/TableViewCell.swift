//
//  TableViewCell.swift
//  PullPageControl
//
//  Created by Avvakumov Dmitry on 15.07.2018.
//  Copyright © 2018 Dmitry Avvakumov. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell, TableCellProtocol {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithModel(model: TableRawProtocol, animated:Bool) {
        guard let m = model as? TableModel else { return }
        
        titleLabel.text = m.title
    }
}
