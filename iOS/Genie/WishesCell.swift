//
//  WishesCell.swift
//  Genie
//
//  Created by Vamsee Chamakura on 20/12/15.
//  Copyright © 2015 genie. All rights reserved.
//

import UIKit

class WishesCell: UITableViewCell {
    @IBOutlet weak var wishHeading: UILabel!
    @IBOutlet weak var wishDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func wishClicked(sender: UIButton) {
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
