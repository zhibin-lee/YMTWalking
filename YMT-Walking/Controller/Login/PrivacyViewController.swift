//
//  PrivacyViewController.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/4/26.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController {
    
    let userDefault = UserDefaults.standard

    @IBOutlet weak var webPrivacy: WKWebView!
    @IBOutlet weak var btnAgree: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hasAcceptedPrivacy()
        
        setStyle()
        let request = URLRequest(url: URL(string: Constants.urlPrivacy)!)
        webPrivacy?.load(request)
        // Do any additional setup after loading the view.
    }
    
    func setStyle(){
        self.title = NSLocalizedString("login_privacy_title", comment: "")
        self.btnAgree?.setTitle(NSLocalizedString("login_privacy_btnAccept", comment: ""), for: .normal)
        btnAgree?.layer.cornerRadius = 10
    }
    
    func hasAcceptedPrivacy (){
        if let isAccept = userDefault.value(forKey: Constants.userDefault_AcceptPrivacy){
            if (isAccept) as! Bool{
                if let controller = storyboard?.instantiateViewController(withIdentifier: "LoginViewController"){
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: true, completion: nil)
                }
            }
        }
        else{
            print("YMTWalking : has not Accepted")
        }
    }

    @IBAction func btnAgreeOnClick(_ sender: UIButton) {
        userDefault.set(true, forKey: Constants.userDefault_AcceptPrivacy)
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
