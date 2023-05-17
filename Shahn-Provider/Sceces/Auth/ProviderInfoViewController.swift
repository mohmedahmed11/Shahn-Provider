//
//  ProviderInfoViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/14/23.
//

import UIKit

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
    @IBOutlet weak var payType: UITextField!
    
    @IBOutlet var categories: [UIButton]!
    
    var images:[UIImage] = []
    var selectedCategories: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func openCamera() {
        
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
