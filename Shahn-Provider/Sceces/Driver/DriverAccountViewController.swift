//
//  DriverAccountViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 6/12/23.
//

import UIKit
import SwiftyJSON
import ProgressHUD

class DriverAccountViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var idNumber: UILabel!
    @IBOutlet weak var carType: UILabel!
    @IBOutlet weak var serviceType: UILabel!
    
    var user: JSON!

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
        guard let request = Glubal.getSubProviders(userId: UserDefaults.standard.integer(forKey: "userIsIn"), action: "my_data").getRequest() else {return}
        
        NetworkManager.instance.request(with: request, decodingType: JSON.self, errorModel: ErrorModel.self) { [weak self] result in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                if data["operation"].boolValue == true {
                    
                    self.user = data["data"]
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
            self.city.text = user["city_name"].stringValue+" - "+user["area"].stringValue
            self.location.text = user["lat"].stringValue+" - "+user["lon"].stringValue
            
            self.idNumber.text = user["identity"].string
            self.carType.text = user["car_type"].string
            
            if user["service_type"].intValue == 1 {
                serviceType.text = "النقل البري"
            }else if user["service_type"].intValue == 2 {
                serviceType.text = "صيانة سيارات"
            }else if user["service_type"].intValue == 3 {
                serviceType.text = "التخزين"
            }else if user["service_type"].intValue == 4 {
                serviceType.text = "لوبد"
            }
        
        }
        
    }
    
    @IBAction func logout() {
        AlertHelper.showOkCancel(message: "هل ترغب في تسجيل الخروج") {
            UserDefaults.standard.removeObject(forKey: "userIsIn")
            UserDefaults.standard.removeObject(forKey: "user_phone")
            self.parent?.parent?.navigationController?.popToRootViewController(animated: true)
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
