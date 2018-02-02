//
//  BuildingTableViewCell.swift
//  CampusWalk
//
//  Created by Alejandro Andrade on 10/17/17.
//  Copyright © 2017 Alejandro Andrade. All rights reserved.
//

import UIKit

class BuildingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var code : UILabel!
    @IBOutlet weak var year : UILabel!
    @IBOutlet weak var photo : UIImageView!
    @IBOutlet weak var detail: UITextView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
