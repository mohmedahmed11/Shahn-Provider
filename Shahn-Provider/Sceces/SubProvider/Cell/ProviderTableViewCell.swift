//
//  ProviderTableViewCell.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit
import SwiftyJSON

class ProviderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var idNumber: UILabel!
    @IBOutlet weak var carType: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var trushBtn: UIButton!
    @IBOutlet weak var pinBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(with provider: JSON) {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
