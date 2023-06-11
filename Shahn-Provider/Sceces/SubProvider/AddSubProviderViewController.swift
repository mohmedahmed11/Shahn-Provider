//
//  AddSubProviderViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit
import SwiftyJSON
import Alamofire
import ProgressHUD
import CoreLocation

class AddSubProviderViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var area: UITextField!
    @IBOutlet weak var idNumber: UITextField!
    @IBOutlet weak var carType: UITextField!
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet var categories: [UIButton]!
    var selectedCategory = -1
    var cities: [JSON] = []
    var location: CLLocationCoordinate2D!
    
    var pickerView = UIPickerView()
    var currentTextField = UITextField()
    
    var selectedCityId = 0
    
    var presenter: SubProvidersPresenter?
    var isForUpdate: Bool = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = SubProvidersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        loadCities()
        // Do any additional setup after loading the view.
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
    
    @IBAction func categorySelection(_ sender: UIButton) {
        
        if selectedCategory == sender.tag {
            sender.backgroundColor = .systemBackground
            selectedCategory = -1
            return
        }
        
        for item in categories {
            item.backgroundColor = .systemBackground
            selectedCategory = -1
        }
        
        sender.backgroundColor = UIColor(named: "PrimaryColor")
        selectedCategory = sender.tag
    }
    
    @IBAction func picLocation() {
        self.performSegue(withIdentifier: "picLocation", sender: nil)
    }
    
    @IBAction func submitAction() {
        if name.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if phone.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if city.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if area.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if location == nil {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if idNumber.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if carType.text!.isEmpty {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        if selectedCategory == -1 {
            AlertHelper.showAlert(message: "عفواً جميع البيانات مطلوبة")
            return
        }
        
        sendData()
    }
    
    func sendData() {
        presenter?.createSubProvider(with: ["action": isForUpdate ? "update" : "create",
                                            "provider_id": UserDefaults.standard.string(forKey: "userIsIn")!,
                                            "name": name.text!,
                                            "phone": phone.text!,
                                            "city_id": "\(selectedCityId)",
                                            "area": area.text!,
                                            "lat": "\(location.latitude)",
                                            "lon": "\(location.latitude)",
                                            "identity": idNumber.text!,
                                            "service_type": "\(selectedCategory)",
                                            "car_type": carType.text!])
    }
    
    func startProgress() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
    }
    
    func stopProgress() {
        ProgressHUD.dismiss()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "picLocation" {
            let vc = segue.destination as! PicAddressViewController
            vc.IsForPicing = true
            vc.delegate = self
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension AddSubProviderViewController: PicLocation {
    func picAdd(location: CLLocationCoordinate2D) {
        self.location = location
        self.locationLbl.text = "\(location.latitude) - \(location.longitude)"
        
    }
}

extension AddSubProviderViewController: AddSubProviderViewDelegate {
    func didCreateProvider(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.navigationController?.popViewController(animated: true)
            }else {
                AlertHelper.showAlert(message: "عفواً لم يتم الحفظ")
            }
        case .failure(let error):
            AlertHelper.showAlert(message: "حدث خطأ اعد المحاولة")
            print(error)
        }
    }
}

extension AddSubProviderViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource  {
    
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
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == city {
            return self.cities.count
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == city {
            return self.cities[row]["name"].string
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == city {
            self.selectedCityId = self.cities[row]["id"].intValue
            self.city.text = self.cities[row]["name"].string
        }
        self.view.endEditing(true)
    }
}
