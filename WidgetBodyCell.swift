//
//  WidgetCell.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-12-27.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit

class WidgetBodyCell: UITableViewCell {

    @IBOutlet weak var snameDirection: UILabel!
    @IBOutlet weak var firstDep: UILabel!
    @IBOutlet weak var secondDep: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
