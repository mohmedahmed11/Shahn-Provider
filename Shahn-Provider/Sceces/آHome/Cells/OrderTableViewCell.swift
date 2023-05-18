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
        if order["status"].intValue == 0 {
            status.text = "جديد"
        }else if order["status"].intValue == 1 {
            status.text = "معتمد"
        }else if order["status"].intValue == 2 {
            status.text = "تم النفيذ"
        }else if order["status"].intValue == 3 {
            status.text = "ملغي"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
