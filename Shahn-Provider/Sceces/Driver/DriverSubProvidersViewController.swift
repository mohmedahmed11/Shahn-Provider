//
//  DriverSubProvidersViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/12/23.
//


import UIKit
import SwiftyJSON

class DriverSubProvidersViewController: UIViewController {
    
    @IBOutlet weak var optionsSegment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var citiesBtn: UIButton!
    @IBOutlet weak var city: UITextField!
    
    @IBOutlet weak var search: UITextField!
    
    var providers = [JSON]()
    var filtredProviders = [JSON]()
    var cities: [JSON] = []
    
    var presenter: SubProvidersPresenter?
    
    var pickerView = UIPickerView()
    var currentTextField = UITextField()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = SubProvidersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.customNavJannaFont()
        loadCities()
        setupSegments()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.optionsSegment.selectedSegmentIndex = 0
        presenter?.loadSubProviders(action: "support_services")
    }
    
    func loadCities() {
        guard let request = Glubal.cities.getRequest() else {return}
        self.presenter?.startProgress()
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            self.presenter?.stopProgress()
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
    
    func setupSegments() {
        let seperatorImage = UIImage(named: "line")
        optionsSegment.setDividerImage(seperatorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        let fontAttributes = [NSAttributedString.Key.font: UIFont(name: "BahijJanna", size: 16) ?? .systemFont(ofSize: 16)]
        optionsSegment.setTitleTextAttributes(fontAttributes, for: .normal)
    }
    
    @IBAction func optionChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.filtredProviders = providers
        }else {
            
            self.filtredProviders = providers.filter({ $0["service_type"].intValue == sender.selectedSegmentIndex + 1})
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // segue for open location of provider
        if segue.identifier == "openLocation" {
            let vc = segue.destination as! PicAddressViewController
            vc.locationJSON = sender as? JSON
            vc.IsForPicing = false
        }else if segue.identifier == "editProvider" {
            let vc = segue.destination as! AddSubProviderViewController
            vc.isForUpdate = true
            vc.provider = sender as? JSON
        }
        // Pass the selected object to the new view controller.
    }
    

}

extension DriverSubProvidersViewController: SubProvidersViewDelegate {
    func didReciveSubProviders(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            if data["operation"].boolValue == true {
                self.providers = data["data"].arrayValue
                self.filtredProviders = self.providers
                if !self.providers.isEmpty {
                    self.tableView.backgroundView = nil
                }else {
                    self.addNoData()
                }
            }else {
                self.addNoData()
            }
            self.tableView.reloadData()
        case .failure(let error):
            self.faildLoading(icon: UIImage(named: "reload"), content: "حدث خطأ اعد المحاولة")
            print(error)
        }
    }
    
    func didDeleteProvider(with result: Result<JSON, Error>) {}
    
    func addNoData() {
        let error = noDataFoundNip()
        error.frame.size.height = 200
        error.content.text = "لايوجد مزودى خدمات"
        self.tableView.backgroundView = error
    }
    
    func faildLoading(icon: UIImage?, content: String) {
        let error = noUserDataNotLoadedNip(nil, content)
        error.frame = self.tabBarController?.tabBar.frame ?? .zero
        error.reloadData = {
            self.presenter?.loadSubProviders(action: "support_services")
            error.removeFromSuperview()
        }
        self.tabBarController?.view.addSubview(error)
    }
}

extension DriverSubProvidersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtredProviders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DSubProviderTableViewCell
        cell.setUI(with: filtredProviders[indexPath.row])
        cell.call = {
            self.makeCall(phoneNumber: self.filtredProviders[indexPath.row]["phone"].stringValue)
        }
        cell.whatsapp = {
            self.openWhatsapp(phoneNumber: self.filtredProviders[indexPath.row]["phone"].stringValue)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
    
    func makeCall(phoneNumber: String) {
     
        let appURL = NSURL(string: "tel://+966\(phoneNumber)")!
        let webURL = NSURL(string: "tel://+966\(phoneNumber)")!


        if UIApplication.shared.canOpenURL(appURL as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL as URL)
            }
        } else {
            //redirect to safari because the user doesn't have Instagram
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL as URL)
            }
        }
    }
    
    func openWhatsapp(phoneNumber: String) {
        
        let appURL = NSURL(string: "https://api.whatsapp.com/send?text=&phone=966\(phoneNumber)")!
        let webURL = NSURL(string: "https://web.whatsapp.com/send?text=&phone=966\(phoneNumber)")!

        if UIApplication.shared.canOpenURL(appURL as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL as URL)
            }
        } else {
            //redirect to safari because the user doesn't have Instagram
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(webURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(webURL as URL)
            }
        }
    }
    
}


extension DriverSubProvidersViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func picCity() {
        self.city.becomeFirstResponder()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        currentTextField = textField
        if currentTextField == city {
            city.inputView = pickerView
        }
    }
    
    @IBAction func valueChanged(_ textField: UITextField) {
        if textField.text!.count > 2 {
            filtredProviders = providers.filter({ $0["city_name"].stringValue == textField.text || $0["name"].stringValue == textField.text || $0["area"].stringValue == textField.text || $0["car_ype"].stringValue == textField.text })
        }else {
            filtredProviders = providers
        }
        tableView.reloadData()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if currentTextField == city {
            return self.cities.count + 1
        }
        return 0
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if currentTextField == city {
            if row == 0 {
                return "كل المناطق"
            }
            return self.cities[row - 1]["name"].string
                
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if currentTextField == city {
            if row == 0 {
                filtredProviders = providers
                self.citiesBtn.setTitle("كل المناطق", for: .normal)
            }else {
                filtredProviders = providers.filter({ $0["city_id"].intValue == self.cities[row - 1]["id"].intValue })
                self.citiesBtn.setTitle(self.cities[row - 1]["name"].string, for: .normal)
            }
            tableView.reloadData()
        }
        self.view.endEditing(true)
    }
}
