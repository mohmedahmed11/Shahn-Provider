//
//  DSubProviderTableViewCell.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/12/23.
//

import UIKit
import SwiftyJSON

class DSubProviderTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var carType: UILabel!
    
    
    var call: (() -> Void)?
    var whatsapp: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(with provider: JSON) {
        name.text = provider["name"].string
        phone.text = provider["contact"].string
        city.text = provider["city_name"].stringValue+" - "+provider["area"].stringValue
        distance.text = "0.0 KM"
        carType.text = provider["car_type"].string
        
        if provider["service_type"].intValue == 1 {
            type.text = "النقل البري"
        }else if provider["service_type"].intValue == 2 {
            type.text = "صيانة سيارات"
        }else if provider["service_type"].intValue == 3 {
            type.text = "التخزين"
        }else if provider["service_type"].intValue == 4 {
            type.text = "لوبد"
        }
    }

    @IBAction func makeCall() {
        self.call?()
    }
    
    @IBAction func openWhatsapp() {
        self.whatsapp?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
