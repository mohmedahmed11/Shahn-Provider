//
//  AddLoadViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit

class AddLoadViewController: UIViewController {

    @IBOutlet weak var serialNumber: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var provider: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction() {
        if serialNumber.text!.isEmpty {
            return
        }
        
        if weight.text!.isEmpty {
            return
        }
        
        if provider.text!.isEmpty {
            return
        }
        
        sendData()
    }

    func sendData() {
        
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
