//
//  LoginViewController.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/4/26.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit
import HealthKit
import Alamofire
import AdSupport
import JGProgressHUD

var id : String = ""
var teamTotalSteps : String = ""
var teamAvgSteps : String = ""
var te

var weekTeam : [Person] = []
var monthTeam : [Person] = []

var teamRecord = TeamRecord(teamToatlSteps: "", teamAvgSteps: "", pernalTodaySteps: "", teamBehind: "" )
var steps : [Detail] = []
var info : Info = Info(historyTotalSteps: "", avgSteps: "", totalSteps: "", totalDistance: "", monthAvgSteps: "", monthTotalSteps: "", monthTotalDistance: "", reachTeamCounts: "", behindTeamCounts: "")

let progressHUD : JGProgressHUD = JGProgressHUD(style: .dark)



class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let userDefault = UserDefaults.standard
    
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var txtUserID: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
        hasLogin()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        setStyle()
        txtUserID.delegate = self
        // Do any additional setup after loading the view.
    }
    
    private func authorizeHealthKit() {
        HealthKit.authorizeHealthKit { (authorized, error) in
            
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                
                return
            }
            
            print("YMTWalking : HealthKit Successfully Authorized.")
        }
    }
    
    func setStyle(){
        self.btnLogin?.setTitle(NSLocalizedString("login_login_btnLogin", comment: ""), for: .normal)
        self.title = NSLocalizedString("login_login_title", comment: "")
        self.lblID.text = NSLocalizedString("login_login_id", comment: "")
        
        btnLogin?.layer.cornerRadius = 10
    }
    
    @IBAction func pressLogin(_ sender: UIButton) {
        
        progressHUD.position = JGProgressHUDPosition.center
        progressHUD.animation = JGProgressHUDFadeZoomAnimation()
        progressHUD.textLabel.text = "Loading..."
        progressHUD.show(in: self.view)
        
        txtUserID.endEditing(true)
        
        id = txtUserID.text ?? ""
        let params : [String: String] = ["EmpID" : id,
                                         "DeviceID" : ASIdentifierManager.shared().advertisingIdentifier.uuidString ,
                                         "PushToken" : userDefault.value(forKey: Constants.userDefault_FcmPushToken) as! String ,
                                         "Platform" : "iOS"]
        print("\(params)")
        AF.request(API.login_loginDetail, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let result = value as? [String: AnyObject] {
                    let rcrm: [String : Any]? = result["rcrm"]as? [String : Any]
                    if(rcrm!["RC"] as? Int == 1){
                        self.userDefault.set(id, forKey: Constants.userDefault_ID)
                        self.setData()
                        self.uploadData()
                        
                        //                        self.performSegue(withIdentifier: "goToWalk", sender: nil)
                    }
                    else {
                        let controller = UIAlertController(title: "登入失敗", message: rcrm?["RM"] as! String, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                        progressHUD.dismiss(animated: true)
                    }
                }
                
                break
            case .failure(let error):
                progressHUD.dismiss(animated: true)
                break
            }
        }
    }
    
    func hasLogin(){
        if let ID : String = userDefault.value(forKey: Constants.userDefault_ID) as? String {
            print("YMTWalking : User find \(ID)")
            txtUserID.text = ID
            pressLogin(btnLogin)
            //performSegue(withIdentifier: "goToWalk", sender: nil)
        }
        else {
            print("YMTWalking : never login")
        }
    }
    
    func uploadData(){
        let now = Calendar.current.startOfDay(for:Date())
        let startDate : Date = DateComponents(calendar: Calendar.current, year: 2020, month: 6, day: 1, hour: 0, minute: 0, second: 0).date!
        var lastDate : Date = userDefault.value(forKey: Constants.userDefault_LastDate) as? Date ?? startDate
        
        var dateList : [Date] = []
        while( lastDate <= now){
            print("now \(now), last \(lastDate)")
            dateList.append(lastDate)
            var dateComponet = DateComponents()
            dateComponet.day = 1
            lastDate = Calendar.current.date(byAdding: dateComponet, to: lastDate)!
        }
        for date in dateList{
            HealthKit().retrieveStepCount(date: date) { (steps) in
                
                HealthKit().retrieveDistanceWalkingRunning(date: date) { (distance) in
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
                    dateFormatter.dateFormat = "YYYY/MM/dd"
                    let strDate = dateFormatter.string(from: date)
                    
                    let params : [String: String] = ["EmpID" : id,
                                                     "WalkingDate" : strDate,
                                                     "Steps":String(format:"%.0f", steps),
                                                     "Distance" : String(format:"%.1f", distance)]
                    
                    AF.request(API.upload_uploadData, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            
                            break
                        case .failure(let error):
                            
                            break
                        }
                    }
                }
            }
            self.userDefault.set(date, forKey: Constants.userDefault_LastDate)
        }
        //        self.setData()
        //        progressHUD.dismiss(animated: true)
    }
    
    func setData(){
        
        let now = Date()
        HealthKit().retrieveStepCount(date: now) { (steps) in
            teamRecord.pernalTodaySteps = String(format:"%.0f", steps)
            print("YMTWalking Steps = \(steps)")
        }
        
        let params : [String: String] = ["EmpID" : id]
        
        // get team information
        
        AF.request(API.groupSteps_showGroupSteps, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let result = value as? [String: AnyObject] {
                    let rcrm: [String : Any]? = result["rcrm"]as? [String : Any]
                    if(rcrm!["RC"] as? Int == 1){
                        let data : [String : Any]? = result["results"]?["All"] as? [String : Any]
                        teamTotalSteps = data?["total_step"] as! String
                        teamAvgSteps = data?["avg_step"] as! String
                        teamBehindSteps = data?["difference_step"] as! String
                        
                        let week : [[String : Any]]? = result["results"]?["Week"] as? [[String : Any]]
                        for person in week! {
                            let someone = Person(name: person["EmpName"] as! String, avgSteps: person["avg_step"] as! String, totalSteps: person["total_step"] as! String, totalDistance: person["total_distance"] as! String)
                            weekTeam.append(someone)
                        }
                        
                        let month : [[String : Any]]? = result["results"]?["Month"] as? [[String : Any]]
                        for person in month! {
                            let someone = Person(name: person["EmpName"] as! String, avgSteps: person["avg_step"] as! String, totalSteps: person["total_step"] as! String, totalDistance: person["total_distance"] as! String)
                            monthTeam.append(someone)
                        }
                    }
                    else {
                        let controller = UIAlertController(title: "取得資料錯誤", message: rcrm?["RM"] as! String, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                        progressHUD.dismiss(animated: true)
                    }
                    progressHUD.dismiss(animated: true)
                    self.performSegue(withIdentifier: "goToWalk", sender: nil)
                }
                
                break
            case .failure(let error):

                break
            }
        }
        
        // get detail information
        
        
        AF.request(API.stepDetail_showStepDetail, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let result = value as? [String: AnyObject] {
                    let rcrm: [String : Any]? = result["rcrm"]as? [String : Any]
                    if(rcrm!["RC"] as? Int == 1){
                        let datalist : [[String : Any]]? = result["results"]?["Record_Data"] as? [[String : Any]]
                        for data in datalist! {
                            let detail = Detail(walkingDate: data["date"] as! String, stepsCount: data["step"] as! String, distanceWR: data["distance"] as! String)
                            steps.append(detail)
                        }
                    }
                    else {
                        let controller = UIAlertController(title: "取得資料錯誤", message: rcrm?["RM"] as! String, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                        progressHUD.dismiss(animated: true)
                    }
                }
                
                break
            case .failure(let error):
                
                break
            }
        }
        
        // get strategy information
        AF.request(API.strategyData_showStrategy, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success(let value):
                if let result = value as? [String: AnyObject] {
                    let rcrm: [String : Any]? = result["rcrm"]as? [String : Any]
                    if(rcrm!["RC"] as? Int == 1){
                        let data : [String : Any]? = result["results"] as? [String : Any]
                        info.historyTotalSteps = data?["total_step"] as! String
                        info.avgSteps = data?["week_avg_step"] as! String
                        info.totalSteps = data?["week_total_step"] as! String
                        info.totalDistance = data?["week_total_distance"] as! String
                        info.reachTeamCounts = data?["qualify_team"] as! String
                        info.behindTeamCounts = data?["behind_team"] as! String
                        info.monthAvgSteps = data?["month_avg_step"] as! String
                        info.monthTotalSteps = data?["month_total_step"] as! String
                        info.monthTotalDistance = data?["month_total_distance"] as! String
                    }
                    else {
                        let controller = UIAlertController(title: "取得資料錯誤", message: rcrm?["RM"] as! String, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                        progressHUD.dismiss(animated: true)
                    }
                }
                
                break
            case .failure(let error):
                
                break
            }
        } 
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtUserID.endEditing(true)
        return true
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
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
