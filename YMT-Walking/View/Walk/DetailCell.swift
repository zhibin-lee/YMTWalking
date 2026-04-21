//
//  DetailCell.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/18.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
