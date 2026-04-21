//
//  PersonCell.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/14.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {

    
    @IBOutlet weak var viewPerson: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAvgSteps: UILabel!
    @IBOutlet weak var lblTotalSteps: UILabel!
    @IBOutlet weak var lblTotalDistance: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //viewPerson.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
