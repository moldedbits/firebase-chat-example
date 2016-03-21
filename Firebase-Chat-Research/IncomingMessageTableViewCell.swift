//
//  IncomingMessageTableViewCell.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 21/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class IncomingMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
