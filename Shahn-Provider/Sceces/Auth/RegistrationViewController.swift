//
//  RegestrationViewController.swift
//  iParking
//
//  Created by MacBook Pro on 10/04/1442 AH.
//  Copyright © 1442 Pita Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SafariServices

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var typeComp: UIButton!
    @IBOutlet weak var typeInter: UIButton!
    @IBOutlet weak var typeIndevi: UIButton!
    
    var isAgree: Bool = false
    
    var userPhone = ""
    var userFile: UserFiles?
    var type = "شركة"

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func typeCompAction(_ sender: UIButton) {
        type = "شركة"
        typeComp.backgroundColor = UIColor(named: "PrimaryColor")
        typeInter.backgroundColor = .systemBackground
        typeIndevi.backgroundColor = .systemBackground
    }
    
    @IBAction func typeInterAction(_ sender: UIButton) {
        type = "مؤسسة"
        typeComp.backgroundColor = .systemBackground
        typeInter.backgroundColor = UIColor(named: "PrimaryColor")
        typeIndevi.backgroundColor = .systemBackground
    }
    
    @IBAction func typeIndeviAction(_ sender: UIButton) {
        type = "فرد"
        typeComp.backgroundColor = .systemBackground
        typeInter.backgroundColor = .systemBackground
        typeIndevi.backgroundColor = UIColor(named: "PrimaryColor")
    }
   
    @IBAction func agreement(_ sender: UIButton) {
        if isAgree {
            sender.backgroundColor = .systemBackground
            isAgree.toggle()
        }else{
            sender.backgroundColor = UIColor(named: "PrimaryColor")
            isAgree.toggle()
        }
    }
    
    @IBAction func opentAgreement() {
        if let url = URL(string: "\(Glubal.termsURL.path)"), UIApplication.shared.canOpenURL(url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    
    @IBAction func submitAction() {
      
        if name.text == "" || name.text == " " {
            let errMessage = "عفوا جميع الحقول مطلوبة"
            AlertHelper.showAlert(message: errMessage)
            return
        }
        if phone.text == "" || phone.text == " " {
            let errMessage = "عفوا جميع الحقول مطلوبة"
            AlertHelper.showAlert(message: errMessage)
            return
        }else{
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = Locale(identifier: "EN")
            if let finalText = numberFormatter.number(from: "\(phone.text!)")
            {
                self.userPhone = "\(finalText)"
                if userPhone.count < 9 || userPhone.subString(from: 0, to: 0) != "5" {
                    let errMessage = "رقم الهاتف غير صالح"
                    AlertHelper.showAlert(message: errMessage)
                    return
                }
                
            }else {
                let errMessage = "رقم الهاتف غير صالح"
                AlertHelper.showAlert(message: errMessage)
                return
            }
        }
       
        if !isAgree {
            let errMessage = "عفوا الرجاء الموافقة علي الشروط والاحكام"
            AlertHelper.showAlert(message: errMessage)
            return
        }
        
        sendData()
    }
    

    func sendData() {
        
        AppManager.shared.authUser = User(id: "0", name: name.text!, phone: self.userPhone, type: self.type, action: "register")
        AppManager.shared.authUser?.userCode = Int.random(in: 1111 ... 9999)
        
        guard let user = AppManager.shared.authUser else {
            return
        }
        
        let message = "تطبيق \(APP_NAME) رمز تفعيلك هو : \(user.userCode)"
        let parameters:Parameters = ["message": message.utf8,"phone": "966\(user.phone!)"]
        
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.sms.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success:
                self.performSegue(withIdentifier: "validationCode", sender: self)
            case .failure(let error):
                AlertHelper.showAlert(message: "عفواً فشل التسجيل حاول مرة أخرى")
                print(error.localizedDescription)
            }
        }
        
        
            
    }
 
    @IBAction func valueChanged(_ textField: UITextField) {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        if let finalText = numberFormatter.number(from: "\(textField.text!)")
        {
            textField.text = finalText.stringValue
        }
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

