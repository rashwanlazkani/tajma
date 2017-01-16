//
//  InfoCell.swift
//  Tajma
//
//  Created by Rashwan Lazkani on 2017-01-16.
//  Copyright © 2017 Rashwan Lazkani. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
