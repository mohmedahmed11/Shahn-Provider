//
//  AddSubProviderViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit

class AddSubProviderViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var idNumber: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var carType: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction() {
        
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
