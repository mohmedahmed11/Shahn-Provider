//
//  AddLoadViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit
import SwiftyJSON
import Alamofire
import ProgressHUD

class AddLoadViewController: UIViewController {

    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var provider: UITextField!
    
    var presenter: OrdersPresenter?
    
    var drivers = [JSON]()
    var order: JSON!
    var selectedDriverId: Int = 0
    var pickerView = UIPickerView()
    var currentTextField = UITextField()
    var code: Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = OrdersPresenter(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        presenter?.getSubProviders()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction() {
        if serialNumber.text!.isEmpty {
            return
        }
        
        if weight.text!.isEmpty {
            return
        }
        
        if provider.text!.isEmpty {
            return
        }
        
        sendData()
    }

    func sendData() {
        self.code = Int.random(in: 1111 ... 9999)
        presenter?.addLoad(with: ["order_id": order["id"].stringValue, "offer_id": order["offer_id"].stringValue,"driver_id": "\(selectedDriverId)","wight": weight.text!,"number": serialNumber.text!, "code": "\(code)", "action": "create"])
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

extension AddLoadViewController: AddLoadDelegate {
    func didAddLoad(with result: Result<SwiftyJSON.JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                let loadId = data["id"].intValue
                self.sendSMS(id: loadId)
                self.navigationController?.popViewController(animated: true)
            }else if data["message"].string != nil {
                AlertHelper.showAlert(message: data["message"].stringValue)
            } else {
                AlertHelper.showAlert(message: "عفوا حاول مرة أخري")
            }
        case .failure(let u):
            AlertHelper.showAlert(message: "عفوا حاول مرة أخري")
            print(u.localizedDescription)
        }
    }
    
    func didReciveDrivers(with result: Result<SwiftyJSON.JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.drivers = data["data"].arrayValue
            }
        case .failure(let u):
            print(u.localizedDescription)
        }
    }
    
    func sendSMS(id: Int) {
        let message = "شحنة رقم \(id)# \n الرمز المتسلسل للشحنة \(self.serialNumber.text!) \n رمز الشحنة \(code)"
        let parameters:Parameters = ["message": message.utf8,"phone": "966\(order["user"]["contact"])"]
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.sms.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
        }
    }
    
}

extension AddLoadViewController:  UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func valueChanged(_ textField: UITextField) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        if let finalText = numberFormatter.number(from: "\(textField.text!)")
        {
            textField.text = finalText.stringValue
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == provider {
            if drivers.isEmpty {
                return
            }else {
                provider.inputView = pickerView
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == provider {
            return self.drivers.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == provider {
            return self.drivers[row]["name"].string
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == provider {
            self.selectedDriverId = self.drivers[row]["id"].intValue
            self.provider.text = self.drivers[row]["name"].string
        }
        self.view.endEditing(true)
    }
}
