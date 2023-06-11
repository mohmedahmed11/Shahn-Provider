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
    
    var openEditView: (() -> Void)?
    var deleteProvider: (() -> Void)?
    var openLocatoinView: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(with provider: JSON) {
        name.text = provider["name"].string
        phone.text = provider["phone"].string
        city.text = provider["city_name"].stringValue+" - "+provider["area"].stringValue
        idNumber.text = provider["identity"].string
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

    @IBAction func editProviderAction() {
        self.openEditView?()
    }
    
    @IBAction func deleteAction() {
        self.deleteProvider?()
    }
    
    @IBAction func locationAction() {
        self.openLocatoinView?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
