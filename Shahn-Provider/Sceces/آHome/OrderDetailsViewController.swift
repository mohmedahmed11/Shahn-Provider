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

class OrderDetailsViewController: UIViewController {
    
    var order: JSON!
    var images: [JSON] = []
    
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var wight: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var picLocation: UILabel!
    @IBOutlet weak var dropLocation: UILabel!
    @IBOutlet weak var chargeDate: UILabel!
    @IBOutlet weak var reciverName: UILabel!
    @IBOutlet weak var reciverPhone: UILabel!
    @IBOutlet weak var providerOfferPrice: UILabel!
    @IBOutlet weak var providerOfferDaies: UILabel!
    @IBOutlet weak var chargesBtn: UIView!
    @IBOutlet weak var pricingStack: UIStackView!
    @IBOutlet weak var reciverStack: UIStackView!
    @IBOutlet weak var optionsBtsStack: UIStackView!
    
    var presenter: OrdersPresenter?
    
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
        wight.text = !order["wight"].string!.isEmpty ? "الوزن: \(order["wight"].stringValue)" : "الردود: \(order["circles"].stringValue) ردود"
        details.text = order["details"].string
        chargeDate.text = "تاريخ الشحن: \(order["charge_date"].stringValue)"
        picLocation.text = "الشحن: \(order["pickup_lat"].stringValue) : \(order["pickup_lon"].stringValue)"
        dropLocation.text = "التفريغ: \(order["dropoff_lat"].stringValue) : \(order["dropoff_lon"].stringValue)"
        reciverName.text = order["receiver_name"].string
        reciverPhone.text = order["receiver_phone"].string
        images = order["images"].arrayValue
        imagesCollectionView.reloadData()
        
        if order["offer_status"].intValue > 0 && order["offer_status"].intValue < 5 {
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
            vc.charges = order["charges"].arrayValue
        }
        // Pass the selected object to the new view controller.
    }

}

extension OrderDetailsViewController: PricingOffersStatusDelegate, PricingDelegate {
    func didStatusChanged(with result: Result<JSON, Error>) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func didPriceOffer() {
        self.navigationController?.popToRootViewController(animated: true)
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
