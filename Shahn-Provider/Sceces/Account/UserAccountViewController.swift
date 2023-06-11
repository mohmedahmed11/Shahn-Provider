//
//  UserAccountViewController.swift
//  iParking
//
//  Created by MacBook Pro on 15/04/1442 AH.
//  Copyright © 1442 Pita Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import YPImagePicker

protocol UserAccountViewControllerDelegate {
    func didUpdateProfile()
}

class UserAccountViewController: UIViewController {
    
    var userJson: JSON = []
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var typeComp: UIButton!
    @IBOutlet weak var typeInter: UIButton!
    @IBOutlet weak var typeIndevi: UIButton!
    @IBOutlet weak var loadType: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var registerNumber: UITextField!
    @IBOutlet weak var bankName: UITextField!
    @IBOutlet weak var bankAccount: UITextField!
    @IBOutlet weak var ownerName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var contact: UITextField!
    @IBOutlet weak var payType: UITextField!
    
    @IBOutlet weak var details: UITextView!
    
    @IBOutlet var categories: [UIButton]!
    
    var user: JSON!
    var userContact = ""
    var config = YPImagePickerConfiguration()
    let picker = YPImagePicker()
    var type = "شركة"
    
    var pickerView = UIPickerView()
    var currentTextField = UITextField()
    
    var images:[UIImage] = []
    var selectedCategories: [Int] = []
    var selectedCityId = 0
    var payTypeID = 0
    
    var payTypes = ["الكل" , "دفع إلكتروني" , "عند التوصيل"]
    var loadTypes = ["ثقيل" , "خفيف"]
    var cities = [JSON]()
    var imagesJSON = [JSON]()
    var categoriesJSON = [JSON]()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        hideKeyboardWhenTappedAround()
        loadUserInfo()
        // Do any additional setup after loading the view.
    }
    
    func loadUserInfo() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.getUser.path)", parameters: ["id": UserDefaults.standard.value(forKey: "userIsIn") ?? "-1"], decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                if data["operation"].boolValue == true {
                    AppManager.shared.authUser = User(id: data["user"]["id"].stringValue, name: data["user"]["name"].stringValue, phone: data["user"]["phone"].stringValue, contact: data["user"]["contact"].stringValue)
                    self.user = data["user"]
                    self.cities = data["cities"].arrayValue
                    self.imagesJSON = data["images"].arrayValue
                    self.categoriesJSON = data["categories"].arrayValue
                    self.setData()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func setData() {
        
        if let user = self.user {
            self.name.text = user["name"].string
            self.phone.text = user["phone"].string
            self.contact.text = user["contact"].string
            self.loadType.text = user["load_type"].string
            self.city.text = user["city_name"].string
            self.registerNumber.text = user["register_number"].string
            self.bankAccount.text = user["bank_acount"].string
            self.bankName.text = user["bank_name"].string
            self.ownerName.text = user["accoun_owner_name"].string
            self.payType.text = payTypes[user["payment_type"].intValue]
            self.details.text = user["details"].string
            self.email.text = user["email"].string
            
            self.payTypeID = user["payment_type"].intValue
            self.selectedCityId = user["city_id"].intValue
            
            if user["type"].stringValue == "شركة" {
                typeCompAction(UIButton())
            }else if user["type"].stringValue == "مؤسسة" {
                typeInterAction(UIButton())
            }else if user["type"].stringValue == "فرد" {
                typeIndeviAction(UIButton())
            }
            
            for category in categoriesJSON {
                for item in categories {
                    if item.tag == category["category_id"].intValue {
                        item.backgroundColor = UIColor(named: "PrimaryColor")
                        selectedCategories.append(item.tag)
                    }
                }
            }
            imagesCollectionView.reloadData()
            
        }
        
    }
    
    @IBAction func categorySelection(_ sender: UIButton) {
        for item in selectedCategories {
            if item == sender.tag {
                sender.backgroundColor = .systemBackground
                selectedCategories.removeAll(where: {$0 == sender.tag})
                return
            }
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryColor")
        selectedCategories.append(sender.tag)
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
    
    @IBAction func updateAction() {
        if name.text == "" || name.text == " " {
            return
        }
        
        if loadType.text!.isEmpty {
            AlertHelper.showAlert(message: "نوع الحمولة مطلوب")
            return
        }
        
        if city.text!.isEmpty {
            AlertHelper.showAlert(message: "المنطقة مطلوبة")
            return
        }
        
        if contact.text!.isEmpty {
            AlertHelper.showAlert(message: "رقم التواصل مطلوب")
            return
        }
        
        if payType.text!.isEmpty {
            AlertHelper.showAlert(message: "طريقة الدفع مطلوبة")
            return
        }
        
        if selectedCategories.isEmpty {
            AlertHelper.showAlert(message: "لارجاء إختر واحد من الأقسام")
            return
        }
        
       
        prepareData()
    }
    
    func prepareData() {
        let parameters = ["name": name.text!, "type": type, "load_type": loadType.text!, "city_id": "\(selectedCityId)", "contact": contact.text!, "register_number": registerNumber.text!, "bank_name": bankName.text!, "bank_acount": bankAccount.text!, "accoun_owner_name": ownerName.text!, "email": email.text!, "payment_type": "\(payTypeID)", "details": details.text!, "action": "update", "token": accessToken, "categories": selectedCategories.description, "id": UserDefaults.standard.string(forKey: "userIsIn")!]
        
        
        self.sendUpdate(with: parameters)
    }
    
    func sendUpdate(with parameters: [String: String]) {
        startProgress()
        
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.users.path)", method: .post, parameters: parameters,  decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                print(data)
                if data["operation"].boolValue == true {
                    AlertHelper.showAlert(message: "تم التعديل")
                }else {
                    AlertHelper.showAlert(message:  "عفواً فشل التعديل حاول مرة أخرى")
                }
            case .failure(let error):
                AlertHelper.showAlert(message: "عفواً فشل التعديل حاول مرة أخرى")
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func deleteAccount() {
        AlertHelper.showOkCancel(message: "هل ترغب في حذف الحساب") {
            self.sendDeleteAccount()
        }
    }
    
    func sendDeleteAccount() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.users.path)", method: .post, parameters: ["id": AppManager.shared.authUser!.id, "action": "delete"], decodingType: JSON.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                if data["operation"].boolValue == true {
                    AlertHelper.showOk(message: "تم حذف الحساب") {
                        self.logout()
                    }
                }else {
                    AlertHelper.showAlert(message:  "عفواً فشل الحذف حاول مرة أخرى")
                }
                
            case .failure(let error):
                AlertHelper.showAlert(message: "عفواً فشل الحذف حاول مرة أخرى")
                print(error.localizedDescription)
            }
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "userIsIn")
        UserDefaults.standard.removeObject(forKey: "user_phone")
        self.parent?.parent?.navigationController?.popToRootViewController(animated: true)
    
    }
    
    func startProgress() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
    }
    
    func stopProgress() {
        ProgressHUD.dismiss()
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


extension UserAccountViewController:  UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        if currentTextField == city {
            city.inputView = pickerView
        }else if currentTextField == loadType {
            loadType.inputView = pickerView
        }else if currentTextField == payType {
            payType.inputView = pickerView
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == city {
            return self.cities.count
        }else if currentTextField == loadType {
            return self.loadTypes.count
        }else if currentTextField == payType {
            return self.payTypes.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == city {
            return self.cities[row]["name"].string
        }else if currentTextField == loadType {
            return self.loadTypes[row]
        }else if currentTextField == payType {
            return self.payTypes[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == city {
            self.selectedCityId = self.cities[row]["id"].intValue
            self.city.text = self.cities[row]["name"].string
        }else if currentTextField == loadType {
            self.loadType.text = loadTypes[row]
        }else if currentTextField == payType {
            self.payType.text = payTypes[row]
            self.payTypeID = row
        }
        self.view.endEditing(true)
    }
}

extension UserAccountViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesJSON.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        if let url = URL(string: Glubal.imageBaseurl.path+imagesJSON[indexPath.row]["image"].stringValue) {
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "logo"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return .init(width: size, height: size)
    }
}
