//
//  SubProvidersViewController.swift
//  Shahn-Provider
//
//  Created by Mohamed Ahmed on 5/17/23.
//

import UIKit
import SwiftyJSON

class SubProvidersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var providers = [JSON]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavJannaFont()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addProvider() {
        self.performSegue(withIdentifier: "addProvider", sender: nil)
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

extension SubProvidersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProviderTableViewCell
        cell.setUI(with: JSON())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
    }
}
