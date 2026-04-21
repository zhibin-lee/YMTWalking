//
//  EverybodyViewController.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/15.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit
import Alamofire

class EverybodyViewController: UIViewController {

    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var sgcPeriod: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        

        //lblInfo.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    func setStyle(){
        self.title = NSLocalizedString("walk_everybody_title", comment: "")
        lblInfo.text = "\n"
        lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblTotalSteps", comment: "") + " : "  + info.historyTotalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
        lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblWeekAvgSteps", comment: "") + " : " + info.avgSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
        lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblWeekTotalSteps", comment: "") + " : " + info.totalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
        lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblWeekTotalDistance", comment: "") + " : " + info.totalDistance + " " + NSLocalizedString("walk_detail_unitDistance", comment: "") + "\n"
        lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblReachTeam", comment: "") + " : " + info.reachTeamCounts + "\n"
        lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblBehindTeam", comment: "") + " : " + info.behindTeamCounts + "\n"
        
        self.sgcPeriod?.setTitle(NSLocalizedString("walk_team_unitWeek", comment: ""), forSegmentAt: 0)
        self.sgcPeriod?.setTitle(NSLocalizedString("walk_team_unitMonth", comment: ""), forSegmentAt: 1)
        self.sgcPeriod.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        self.sgcPeriod.tintColor = UIColor.init(named: "color_yamaha_racing_blue")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sgcPeriodChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            lblInfo.text = "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblTotalSteps", comment: "") + " : "  + info.historyTotalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblWeekAvgSteps", comment: "") + " : " + info.avgSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblWeekTotalSteps", comment: "") + " : " + info.totalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblWeekTotalDistance", comment: "") + " : " + info.totalDistance + " " + NSLocalizedString("walk_detail_unitDistance", comment: "") + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblReachTeam", comment: "") + " : " + info.reachTeamCounts + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblBehindTeam", comment: "") + " : " + info.behindTeamCounts + "\n"
        }
        else{
            lblInfo.text = "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblTotalSteps", comment: "") + " : "  + info.historyTotalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblMonthAvgSteps", comment: "") + " : " + info.monthAvgSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! + NSLocalizedString("walk_everybody_lblMonthTotalSteps", comment: "") + " : " + info.monthTotalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "") + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblMonthTotalDistance", comment: "") + " : " + info.monthTotalDistance + " " + NSLocalizedString("walk_detail_unitDistance", comment: "") + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblReachTeam", comment: "") + " : " + info.reachTeamCounts + "\n"
            lblInfo.text = lblInfo.text! +  NSLocalizedString("walk_everybody_lblBehindTeam", comment: "") + " : " + info.behindTeamCounts + "\n"
        }
    }
    
    
    @IBAction func btnRefreshOnclick(_ sender: Any) {
        
        progressHUD.show(in: self.view)
        
        let params : [String: String] = ["EmpID" : id]
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
                        progressHUD.dismiss(animated: true)
                        self.viewDidLoad()
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
                    progressHUD.dismiss(animated: true)
                break
            }
            
        }
    }
    
}
