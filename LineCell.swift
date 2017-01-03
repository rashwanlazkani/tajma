//
//  LineCell.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2016-11-07.
//  Copyright © 2016 Rashwan Lazkani. All rights reserved.
//

import UIKit

class LineCell: UITableViewCell {

    @IBOutlet weak var snameView: UIImageView!
    @IBOutlet weak var snameLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var checkbox: UIImageView!
    @IBOutlet weak var firstDeparture: UILabel!
    @IBOutlet weak var secondDeparture: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
