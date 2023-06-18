//
//  ChargesTableViewCell.swift
//  Shahn
//
//  Created by Mohamed Ahmed on 5/6/23.
//

import UIKit
import SwiftyJSON

class ChargesTableViewCell: UITableViewCell {
    
    var charge: JSON!
    
    @IBOutlet weak var chargeId: UILabel!
    @IBOutlet weak var serial: UILabel!
    @IBOutlet weak var wight: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var driverStack: UIStackView!
    
    var invoiceDetails: (() -> Void)?
    var fallowDriver: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(with charge: JSON) {
        self.chargeId.text = "#\(charge["id"].stringValue)"
        self.serial.text = "#\(charge["number"].stringValue)"
        self.date.text = charge["created_at"].string
        self.wight.text = charge["wight"].stringValue+" طن"
        
        if charge["status"].intValue == 0 {
            status.text = "جاري الشحن"
            status.textColor = .systemBlue
        }else if charge["status"].intValue == 1 {
            status.text = "تم التنفيذ"
            status.textColor = .systemGreen
        }else if charge["status"].intValue == 2 {
            status.text = "ملغي"
            status.textColor = .systemRed
        }
    }
    
    @IBAction func showInvoide() {
        invoiceDetails?()
    }
    
    @IBAction func showDriverInMap() {
        fallowDriver?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
