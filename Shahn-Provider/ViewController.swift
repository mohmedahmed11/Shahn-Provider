//
//  ViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/7/23.
//

import UIKit
import ProgressHUD
import SwiftyJSON

class ViewController: UIViewController {

    var timer = Timer()
    var doutCount = 0;
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var reloadBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        self.reloadBtn.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setTimer()
    }
    
    
    func setTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(setLoadingLabel), userInfo: nil, repeats: true)
        timer.fire()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // your code here
            self.loadAppInfo()
        }
        
    }
    
    @objc func setLoadingLabel() {
        self.loadingLabel.textColor = .label
        if doutCount < 3 {
            loadingLabel.text! += "."
            doutCount += 1
        }else {
            loadingLabel.text = "جار التحميل"
            doutCount = 0
        }
    }

    
    
    
    func faildLoading() {
        timer.invalidate()
        self.loadingLabel.text = "فشل التحميل"
        self.reloadBtn.isHidden = false
        self.loadingLabel.textColor = .systemRed
    }
    
    
    @IBAction func reload() {
        self.reloadBtn.isHidden = true
        self.setTimer()
    }
    
    
    func segue() {
        if UserDefaults.standard.value(forKey: "userIsIn") != nil {
            loadUserInfo()
            if UserDefaults.standard.string(forKey: "userType") == "driver" {
                self.performSegue(withIdentifier: "toDriverHome", sender: nil)
            }else {
                self.performSegue(withIdentifier: "toHome", sender: nil)
            }
        }else {
            self.performSegue(withIdentifier: "doSign", sender: nil)
        }
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
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateToken() {
        NetworkManager.instance.request(with: "\(Glubal.baseurl.path)\(Glubal.users.path)", method: .post, parameters: ["token": accessToken, "id": UserDefaults.standard.string(forKey: "userIsIn")!, "action": "updateToken"],  decodingType: JSON.self, errorModel: ErrorModel.self){ _ in }
    }
    
    
    func loadAppInfo() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.show()
        NetworkManager.instance.request(with: Glubal.about.getRequest(parameters: [:])!, decodingType: AboutResponse.self, errorModel: ErrorModel.self) { result in
            ProgressHUD.dismiss()
            switch result {
            case .success(let data):
                AppManager.shared.about = data.about
                AppManager.shared.sms = data.sms
                self.segue()
                print(data.about.about)
            case .failure(let error):
                self.faildLoading()
                print(error.localizedDescription)
            }
        }
    }

}
