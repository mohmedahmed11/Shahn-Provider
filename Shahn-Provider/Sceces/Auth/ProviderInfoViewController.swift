//
//  ProviderInfoViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/14/23.
//

import UIKit
import YPImagePicker
import SwiftyJSON
import Alamofire
import ProgressHUD

class ProviderInfoViewController: UIViewController {

    @IBOutlet weak var name: UITextField!
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
    
    var config = YPImagePickerConfiguration()
    let picker = YPImagePicker()
    
    var pickerView = UIPickerView()
    var currentTextField = UITextField()
    
    var images:[UIImage] = []
    var selectedCategories: [Int] = []
    var selectedCityId = 0
    var payTypeID = 0
    
    var payTypes = ["الكل" , "دفع إلكتروني" , "عند التوصيل"]
    var loadTypes = ["ثقيل" , "خفيف"]
    var cities = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configerImagePicer()
        setPreparedDate()
        loadCities()
        details.placeholder = "وصف عن الخدمة"
        // Do any additional setup after loading the view.
    }
    
    func configerImagePicer() {
        config.isScrollToChangeModesEnabled = false
        config.onlySquareImagesFromCamera = false
        config.usesFrontCamera = false
        config.shouldSaveNewPicturesToAlbum = false
        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo]
        config.showsCrop = .rectangle(ratio: 1.0)
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
        // Do any additional setup after loading the view.
    }
    
    func setPreparedDate() {
        self.name.text = AppManager.shared.authUser.name
        self.phone.text = AppManager.shared.authUser.phone
    }
    
    func loadCities() {
        guard let request = Glubal.cities.getRequest() else {return}
        self.startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                if data["operation"].boolValue == true {
                    self.cities = data["data"].arrayValue
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func openCamera() {
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                if let img = photo.modifiedImage {
                    self.images.append(img)
                }else {
                    let img = photo.originalImage
                    self.images.append(img)
                }
            }
            self.imagesCollectionView.reloadData()
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
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

    @IBAction func submit() {
        if loadType.text!.isEmpty {
            AlertHelper.showAlert(message: "نوع الحمولة مطلوب")
            return
        }
        
        if city.text!.isEmpty {
            AlertHelper.showAlert(message: "المنطقة مطلوبة")
            return
        }
        
        if images.isEmpty {
            AlertHelper.showAlert(message: "الصور مطلوبة")
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
        let data = MultipartFormData()
        data.append(AppManager.shared.userJSON["name"].stringValue.data(using: .utf8)!, withName: "name")
        data.append(AppManager.shared.userJSON["phone"].stringValue.data(using: .utf8)!, withName: "phone")
        data.append(AppManager.shared.userJSON["type"].stringValue.data(using: .utf8)!, withName: "type")
        data.append(loadType.text!.data(using: .utf8)!, withName: "load_type")
        data.append("\(selectedCityId)".data(using: .utf8)!, withName: "city_id")
        data.append(contact.text!.data(using: .utf8)!, withName: "contact")
        data.append(registerNumber.text!.data(using: .utf8)!, withName: "register_number")
        data.append(bankName.text!.data(using: .utf8)!, withName: "bank_name")
        data.append(bankAccount.text!.data(using: .utf8)!, withName: "bank_acount")
        data.append(ownerName.text!.data(using: .utf8)!, withName: "accoun_owner_name")
        data.append(email.text!.data(using: .utf8)!, withName: "email")
        
        data.append("\(payTypeID)".data(using: .utf8)!, withName: "payment_type")
        data.append(details.text!.data(using: .utf8)!, withName: "details")
        data.append("register".data(using: .utf8)!, withName: "action")
        
        do {
            let terms = try JSONEncoder().encode(selectedCategories)
            data.append(terms, withName: "categories")
        }catch {
            AlertHelper.showAlert(message: "الرجاء مراجعة شاشة مزودي الخدمات")
            return
        }
        
        for index in 0..<images.count {
            if let imageData = images[index].jpegData(compressionQuality: 0.5) {
                data.append(imageData, withName: "images[\(index)]", fileName: "IMG.jpg", mimeType: "image/jpg")
            }
        }
        self.createUser(with: data)
    }
    
    func createUser(with data: MultipartFormData) {
        startProgress()
        NetworkManager.instance.requestWithFiles(with: data, to: "\(Glubal.baseurl.path)\(Glubal.users.path)", headers: Glubal.baseurl.mutipartHeaders, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.stopProgress()
            switch result {
            case .success(let data):
                print(data)
                if data["operation"].boolValue == true {
                    AppManager.shared.authUser?.id = data["user"]["id"].stringValue
                    self.saveUser()
                }else {
                    AlertHelper.showAlert(message:  "عفواً فشل التسجيل حاول مرة أخرى")
                }
            case .failure(let error):
                AlertHelper.showAlert(message: "عفواً فشل التسجيل حاول مرة أخرى")
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUser() {
        UserDefaults.standard.set(AppManager.shared.authUser!.id, forKey: "userIsIn")
        UserDefaults.standard.set(AppManager.shared.authUser!.phone, forKey: "user_phone")
        self.navigationController?.popToRootViewController(animated: true)
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

extension ProviderInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        if indexPath.item != images.count {
            cell.imageView.image = self.images[indexPath.row]
            cell.trushBtn.isHidden = false
            cell.remove = {
                self.images.remove(at: indexPath.row)
                self.imagesCollectionView.reloadData()
            }
        }else {
            cell.imageView.image = UIImage(named: "no-image")
            cell.trushBtn.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == images.count {
            openCamera()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return .init(width: size, height: size)
    }
}

extension ProviderInfoViewController:  UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
