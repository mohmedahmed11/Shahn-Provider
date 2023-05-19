//
//  OrderTableViewCell.swift
//  Shahn
//
//  Created by Mohamed Ahmed on 4/15/23.
//

import UIKit
import SwiftyJSON

class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var orderId: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var wightLbl: UILabel!
    @IBOutlet weak var wight: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var offerLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUI(with order: JSON) {
        orderId.text = "#"+order["id"].stringValue
        type.text = order["type"].string
        wight.text = !order["wight"].string!.isEmpty ? "\(order["wight"].stringValue)" : "\(order["circles"].stringValue) ردود"
        wightLbl.text = !order["wight"].string!.isEmpty ? "الوزن: " : "الردود:"
        date.text = order["created_at"].string
        if order["offer_status"].intValue == 0 || order["offer_status"].intValue == 1 {
            status.text = "جديد"
        }else  if order["offer_status"].intValue == 2 {
            status.text = "معتمد"
        }else if order["offer_status"].intValue == 3 {
            status.text = "تم النفيذ"
        }else if order["offer_status"].intValue == 5 {
            status.text = "ملغي"
        }
        
        if order["offer_status"].intValue == 1 {
            self.offerLbl.text = "تم إسال العرض"
            self.offerLbl.isHidden = false
        }else if order["offer_status"].intValue == 5 {
            self.offerLbl.text = "العرض ملغي"
            self.offerLbl.isHidden = false
        }else {
            self.offerLbl.isHidden = true
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
