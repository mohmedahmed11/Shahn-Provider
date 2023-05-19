//
//  OrderPricingViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/18/23.
//

import UIKit
import SwiftyJSON

protocol PricingDelegate {
    func didPriceOffer()
}

class OrderPricingViewController: UIViewController {
    
    var order: JSON!
    
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var daies: UITextField!
    
    var presenter: OrdersPresenter?
    var delegate: PricingDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = OrdersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func valueChanged(_ textField: UITextField) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        if let finalText = numberFormatter.number(from: "\(textField.text!)")
        {
            textField.text = finalText.stringValue
        }
    }
    
    @IBAction func submit() {
        if price.text!.isEmpty || daies.text!.isEmpty {
            return
        }
        
        self.presenter?.pricingOffer(with: ["offer_id": order["offer_id"].stringValue, "price": price.text!, "daies": daies.text!, "action": "pricing"])
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderPricingViewController: PricingOffersStatusDelegate {
    func didStatusChanged(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            print(data)
            if data["operation"].boolValue == true {
                self.dismiss(animated: true)
                self.delegate?.didPriceOffer()
            }else {
                AlertHelper.showAlert(message: "عفوا أعد المحاولة")
            }
        case .failure:
            AlertHelper.showAlert(message: "عفوا أعد المحاولة")
        }
    }
}
