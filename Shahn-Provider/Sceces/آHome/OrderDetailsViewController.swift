//
//  OrderDetailsViewController.swift
//  Shahn
//
//  Created by Mohamed Ahmed on 4/14/23.
//

import UIKit
import SwiftyJSON
import ImageSlideshow
import Kingfisher
import SafariServices

class OrderDetailsViewController: UIViewController {
    
    var order: JSON!
    var images: [JSON] = []
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var wight: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var picLocationAdd: UILabel!
    @IBOutlet weak var dropLocationAdd: UILabel!
    @IBOutlet weak var picLocation: UILabel!
    @IBOutlet weak var dropLocation: UILabel!
    @IBOutlet weak var chargeDate: UILabel!
    @IBOutlet weak var reciverName: UILabel!
    @IBOutlet weak var reciverPhone: UILabel!
    @IBOutlet weak var providerOfferPrice: UILabel!
    @IBOutlet weak var providerOfferDaies: UILabel!
    @IBOutlet weak var loadsCount: UILabel!
    @IBOutlet weak var payment: UILabel!
    @IBOutlet weak var chargesBtn: UIView!
    @IBOutlet weak var pricingStack: UIStackView!
    @IBOutlet weak var reciverStack: UIStackView!
    @IBOutlet weak var optionsBtsStack: UIStackView!
    @IBOutlet weak var reportBtn: UIView!
    
    var presenter: OrdersPresenter?
    var chargeCount : Int = 0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        presenter = OrdersPresenter(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        // Do any additional setup after loading the view.
    }
    
    func setData() {
        type.text = order["type"].string
        wight.text = order["wight"].intValue != 0  ? "الوزن: \(order["wight"].stringValue) طن" : "الردود: \(order["circles"].stringValue) ردود"
        details.text = order["details"].string
        chargeDate.text = "تاريخ الشحن: \(order["charge_date"].stringValue)"
        picLocation.text = "\(order["pickup_lat"].stringValue) : \(order["pickup_lon"].stringValue)"
        dropLocation.text = "\(order["dropoff_lat"].stringValue) : \(order["dropoff_lon"].stringValue)"
        
        picLocationAdd.text = "الشحن: \(order["pickup_area"].stringValue)"
        dropLocationAdd.text = "التفريغ: \(order["drop_off_area"].stringValue)"
        
        providerOfferPrice.text = "\(order["price"].stringValue) ريال"
        providerOfferDaies.text = "\(order["duration"].stringValue) يوم"
        
        reciverName.text = order["receiver_name"].string
        reciverPhone.text = order["receiver_phone"].string
        images = order["images"].arrayValue
        imagesCollectionView.reloadData()
        
        if order["total_delivery"].intValue > 0 {
            loadsCount.text = "\(order["total_delivery"].intValue) شحنة"
        }
        
        if order["offer_status"].intValue == 2 || order["offer_status"].intValue == 3 {
            self.reportBtn.isHidden = false
            payment.text = order["payment_type"].intValue == 1 ? "دفع عند الوصول" : "دفع ألكتروني"
        }else {
            self.reportBtn.isHidden = true
        }
        
        if order["offer_status"].intValue > 0 && order["offer_status"].intValue < 4 {
            self.pricingStack.isHidden = false
            self.optionsBtsStack.isHidden = true
            if order["offer_status"].intValue > 1 {
                self.reciverStack.isHidden = false
                self.chargesBtn.isHidden = false
            }else {
                self.reciverStack.isHidden = true
                self.chargesBtn.isHidden = true
            }
        }else if order["offer_status"].intValue == 0 {
            self.pricingStack.isHidden = true
            self.optionsBtsStack.isHidden = false
            self.reciverStack.isHidden = true
            self.chargesBtn.isHidden = true
        }else {
            self.pricingStack.isHidden = true
            self.optionsBtsStack.isHidden = true
            self.reciverStack.isHidden = true
            self.chargesBtn.isHidden = true
        }
    }
    
    @IBAction func acceptOrder() {
        self.performSegue(withIdentifier: "pricing", sender: nil)
    }
    
    @IBAction func rejectOrder() {
        AlertHelper.showOkCancel(message: "هل ترفغ في رفض الطلب") {
            self.presenter?.changeOfferStatus(orderId: self.order["id"].intValue, providerId: UserDefaults.standard.integer(forKey: "userIsIn"), status: 5)
        }
    }
    
    @IBAction func openPicInMap() {
//        self.performSegue(withIdentifier: "openLocation", sender: JSON(["lat": order["pickup_lat"].floatValue ,"lon": order["pickup_lon"].floatValue]))
        self.openGoogleMap(latDouble: order["pickup_lat"].floatValue, longDouble: order["pickup_lon"].floatValue)
    }
    
    @IBAction func openDropInMap() {
//        self.performSegue(withIdentifier: "openLocation", sender: JSON(["lat": order["dropoff_lat"].floatValue ,"lon": order["dropoff_lon"].floatValue]))
        self.openGoogleMap(latDouble: order["dropoff_lat"].floatValue, longDouble: order["dropoff_lon"].floatValue)
    }
    
    func openGoogleMap(latDouble: Float, longDouble: Float) {
     if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {  //if phone has an app

          if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
           }}
      else {
             //Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                           UIApplication.shared.open(urlDestination)
                       }
            }

    }
    
    @IBAction func makeCall() {
        let appURL = NSURL(string: "tel://0\(order["receiver_phone"].stringValue)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        let webURL = NSURL(string: "tel://0\(order["receiver_phone"].stringValue)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!


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
    
    @IBAction func openWhatsapp() {
        
        let appURL = NSURL(string: "https://api.whatsapp.com/send?text=&phone=966\(order["receiver_phone"].stringValue)")!
        let webURL = NSURL(string: "https://web.whatsapp.com/send?text=&phone=966\(order["receiver_phone"].stringValue)")!

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
    
    @IBAction func showLoads() {
        if order["total_delivery"].intValue > 0 {
            self.performSegue(withIdentifier: "charges", sender: nil)
        }else {
            AlertHelper.showAlertTextEntry(message: "عدد الشحنات للطلب", placeholderText: "عدد الشحنات", keyboardType: .numberPad) { buttonIndex, textField in
                self.chargeCount = Int(textField.text!)!
                self.presenter?.orderLoadsCount(offerId: self.order["offer_id"].intValue, count: self.chargeCount)
                return
            }
        }
    }
    
    @IBAction func oprnReport() {
        let url = order["invoice"].stringValue
        if let url = URL(string: "\(Glubal.filesBaseurl.path)\(url)"){
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true)
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "pricing" {
            let vc = segue.destination as! OrderPricingViewController
            vc.order = order
            vc.delegate = self
        }else if segue.identifier == "charges" {
            let vc = segue.destination as! OrderLoadsViewController
            vc.order = order
        }else if segue.identifier == "openLocation" {
            let vc = segue.destination as! ShowAddressViewController
            vc.locationJSON = sender as? JSON
        }
        // Pass the selected object to the new view controller.
    }

}

extension OrderDetailsViewController: PricingDelegate, DetailsDelegate {
    func didStatusChanged(with result: Result<JSON, Error>) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didPriceOffer() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didAddLoadsCount(with result: Result<JSON, Error>) {
        switch result {
        case .success(let data):
            print(data)
            if data["operation"].boolValue == true {
                order["total_delivery"] = JSON(self.chargeCount)
                self.performSegue(withIdentifier: "charges", sender: nil)
            }else {
                AlertHelper.showAlert(message: "عفوا أعد المحاولة")
            }
        case .failure:
            AlertHelper.showAlert(message: "عفوا أعد المحاولة")
        }
    }
}

extension OrderDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        if let url = URL(string: Glubal.imageBaseurl.path+images[indexPath.row]["image"].stringValue) {
            cell.imageView.kf.setImage(with: url, placeholder: UIImage(named: "logo"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.frame.height
        return .init(width: size, height: size)
    }
}
