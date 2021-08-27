//
//  MatchTableViewCell.swift
//  CemtrexLabsTest
//
//  Created by Pooja's MacBook Pro on 27/08/21.
//

import UIKit
// make protocol
protocol matchViewController : class {
    func editButtonPressed(tag: Int, cell: MatchTableViewCell)
}


class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    var matchViewController : matchViewController?
    var isStarSelected : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    // star button 
    @IBAction func starButtonPressed(_ sender: UIButton) {
        matchViewController?.editButtonPressed(tag: sender.tag, cell: self)
    }
}
