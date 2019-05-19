//
//  TableViewCell.swift
//  Tinkoff_News
//
//  Created by Антон Шуплецов on 16/05/2019.
//  Copyright © 2019 Антон Шуплецов. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        newsTitleLabel.text = ""
        counterLabel.text = ""

        
    }
}
