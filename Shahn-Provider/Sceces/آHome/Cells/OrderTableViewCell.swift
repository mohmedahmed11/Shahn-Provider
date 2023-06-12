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
        wight.text = order["wight"].intValue != 0 ? "\(order["wight"].stringValue)" : "\(order["circles"].stringValue) ردود"
        wightLbl.text = order["wight"].intValue != 0 ? "الوزن: " : "الردود:"
        date.text = order["created_at"].string
        if order["offer_status"].intValue == 0 {
            status.text = "جديد"
            status.textColor = .systemBlue
        }else if order["offer_status"].intValue == 1 {
            status.text = "تم إسال العرض"
            status.textColor = .systemOrange
        } else if order["offer_status"].intValue == 2 {
            status.text = "معتمد"
            status.textColor = .systemOrange
        }else if order["offer_status"].intValue == 3 {
            status.text = "تم النفيذ"
            status.textColor = .systemGreen
        }else if order["offer_status"].intValue == 4 {
            status.text = "تم إعتماد مزود آخر"
            status.textColor = .systemRed
        }else if order["offer_status"].intValue == 5 {
            status.text = "ملغي"
            status.textColor = .systemRed
        }
        
        if order["offer_status"].intValue == 1 {
            self.offerLbl.text = "تم إسال العرض"
            self.offerLbl.textColor = .systemOrange
            self.offerLbl.isHidden = false
        }else if order["offer_status"].intValue == 5 {
            self.offerLbl.text = "العرض ملغي"
            self.offerLbl.textColor = .systemRed
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
