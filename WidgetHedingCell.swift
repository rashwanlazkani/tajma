//
//  WidgetHedingCell.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-12-28.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WidgetHedingCell: UITableViewCell {

    @IBOutlet weak var stop: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
