//
//  OutgoingMessageTableViewCell.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 21/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class OutgoingMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var seenImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
