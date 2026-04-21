//
//  TeamViewController.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/4/29.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit
import Alamofire

class TeamViewController: UIViewController {
    
    @IBOutlet weak var lblBehindSteps: UILabel!
    @IBOutlet weak var lblSteps: UILabel!
    @IBOutlet weak var lblTeamAvgSteps: UILabel!
    @IBOutlet weak var lblTeamTotalSteps: UILabel!
    @IBOutlet weak var sgcPeriod: UISegmentedControl!
    @IBOutlet weak var tbvTeam: UITableView!
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStyle()
        
        self.tbvTeam.dataSource = self
        self.tbvTeam.delegate = self
        self.tbvTeam.allowsSelection = false
        self.tbvTeam.backgroundColor = UIColor(named: "color_yamaha_grey")
        self.tbvTeam.register(UINib(nibName: "PersonCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
    }
    
    func setStyle() {
        
        self.lblTeamTotalSteps.text = NSLocalizedString("walk_team_lblTotalSteps", comment: "") + " : " + teamTotalSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "")
        self.lblTeamAvgSteps.text = NSLocalizedString("walk_team_lblAvgSteps", comment: "") + " : " + teamAvgSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "")
        self.lblSteps.text = NSLocalizedString("walk_team_lblTodaySteps", comment: "") + " : " + teamRecord.pernalTodaySteps + " " + NSLocalizedString("walk_team_unitStep", comment: "")
        
        self.sgcPeriod?.setTitle(NSLocalizedString("walk_team_unitWeek", comment: ""), forSegmentAt: 0)
        self.sgcPeriod?.setTitle(NSLocalizedString("walk_team_unitMonth", comment: ""), forSegmentAt: 1)
        
        if teamBehindSteps != "0" {
            self.lblBehindSteps.backgroundColor = UIColor(named: "color_yamaha_red")
            self.lblBehindSteps.text = NSLocalizedString("walk_team_lblBehind", comment: "") + "\n" + teamBehindSteps + " " + NSLocalizedString("walk_team_unitStep", comment: "")
        } else {
            self.lblBehindSteps.backgroundColor = UIColor(named: "color_yamaha_green")
            self.lblBehindSteps.text = NSLocalizedString("walk_team_lblAchieved", comment: "")
        }
        
        sgcPeriod.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: UIControl.State.selected)
        sgcPeriod.tintColor = UIColor.init(named: "color_yamaha_racing_blue")
        tbvTeam.backgroundColor = UIColor.clear
    }
    
    @IBAction func sgcPeriodChange(_ sender: UISegmentedControl) {
        self.tbvTeam.reloadData()
    }
    
    @IBAction func btnHealth_OnClick(_ sender: Any) {
        guard let url = URL(string: "x-apple-health://") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func btnRefreshOnclick(_ sender: Any) {
        progressHUD.show(in: self.view)
        
        // 先從 HealthKit 讀今天的步數，更新畫面後再上傳並撈資料
        let today = Calendar.current.startOfDay(for: Date())
        HealthKit().retrieveStepCount(date: today) { [weak self] steps in
            guard let self = self else { return }
            DispatchQueue.main.async {
                // 更新全域的今日步數，讓 setStyle() 能拿到最新值
                teamRecord.pernalTodaySteps = String(format: "%.0f", steps)
            }
            
            self.uploadData {
                let params: [String: String] = ["EmpID": id]
                
                AF.request(API.groupSteps_showGroupSteps,
                           method: .post,
                           parameters: params,
                           encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        guard let result = value as? [String: AnyObject] else {
                            DispatchQueue.main.async { progressHUD.dismiss(animated: true) }
                            return
                        }
                        
                        let rcrm = result["rcrm"] as? [String: Any]
                        
                        if rcrm?["RC"] as? Int == 1 {
                            if let data = result["results"]?["All"] as? [String: Any] {
                                teamTotalSteps = data["total_step"] as? String ?? "0"
                                teamAvgSteps   = data["avg_step"]   as? String ?? "0"
                                teamBehindSteps = data["difference_step"] as? String ?? "0"
                            }
                            
                            if let week = result["results"]?["Week"] as? [[String: Any]] {
                                weekTeam = week.compactMap { person in
                                    guard
                                        let name     = person["EmpName"]        as? String,
                                        let avg      = person["avg_step"]       as? String,
                                        let total    = person["total_step"]     as? String,
                                        let distance = person["total_distance"] as? String
                                    else { return nil }
                                    return Person(name: name, avgSteps: avg, totalSteps: total, totalDistance: distance)
                                }
                            }
                            
                            if let month = result["results"]?["Month"] as? [[String: Any]] {
                                monthTeam = month.compactMap { person in
                                    guard
                                        let name     = person["EmpName"]        as? String,
                                        let avg      = person["avg_step"]       as? String,
                                        let total    = person["total_step"]     as? String,
                                        let distance = person["total_distance"] as? String
                                    else { return nil }
                                    return Person(name: name, avgSteps: avg, totalSteps: total, totalDistance: distance)
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.setStyle()
                                self.tbvTeam.reloadData()
                                progressHUD.dismiss(animated: true)
                            }
                            
                        } else {
                            let msg = rcrm?["RM"] as? String ?? "未知錯誤"
                            DispatchQueue.main.async {
                                let controller = UIAlertController(title: "取得資料錯誤", message: msg, preferredStyle: .alert)
                                controller.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(controller, animated: true)
                                progressHUD.dismiss(animated: true)
                            }
                        }
                        
                    case .failure:
                        DispatchQueue.main.async {
                            progressHUD.dismiss(animated: true)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Upload
    
    func uploadData(completion: @escaping () -> Void) {
        let startDate: Date = DateComponents(calendar: Calendar.current, year: 2020, month: 6, day: 1).date!
        let today = Calendar.current.startOfDay(for: Date())
        
        // lastDate 是「上次成功上傳的最後一天」；今天永遠重新上傳，所以比較基準到 yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        var lastSuccessDate: Date = userDefault.value(forKey: Constants.userDefault_LastDate) as? Date ?? startDate

        // 建立需要上傳的日期清單
        // 歷史資料：lastSuccessDate 到 yesterday（成功後才推進 lastDate）
        // 今天：永遠重新上傳，但不更新 userDefault_LastDate
        var historyDates: [Date] = []
        var cursor = lastSuccessDate
        while cursor <= yesterday {
            historyDates.append(cursor)
            cursor = Calendar.current.date(byAdding: .day, value: 1, to: cursor)!
        }
        
        let allDates = historyDates + [today]
        
        guard !allDates.isEmpty else {
            completion()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        var latestSuccessDate: Date? = nil  // 記錄歷史資料中最新的成功日期
        let lock = NSLock()                 // 保護 latestSuccessDate 的多執行緒寫入
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.dateFormat = "YYYY/MM/dd"
        
        for date in allDates {
            dispatchGroup.enter()
            
            HealthKit().retrieveStepCount(date: date) { steps in
                HealthKit().retrieveDistanceWalkingRunning(date: date) { distance in
                    let strDate = dateFormatter.string(from: date)
                    let params: [String: String] = [
                        "EmpID":       id,
                        "WalkingDate": strDate,
                        "Steps":       String(format: "%.0f", steps),
                        "Distance":    String(format: "%.1f", distance)
                    ]
                    
                    AF.request(API.upload_uploadData,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.default)
                    .responseJSON { response in
                        if case .success = response.result {
                            // 只有歷史資料成功才推進 lastDate（今天不算）
                            if date < today {
                                lock.lock()
                                if latestSuccessDate == nil || date > latestSuccessDate! {
                                    latestSuccessDate = date
                                }
                                lock.unlock()
                            }
                        }
                        // 無論成功失敗都 leave，避免 group 永遠不結束
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            // 統一在所有上傳完成後，才更新 userDefault_LastDate
            if let latest = latestSuccessDate {
                self?.userDefault.set(latest, forKey: Constants.userDefault_LastDate)
            }
            completion()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TeamViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath) as! PersonCell
        
        let isWeek = sgcPeriod.selectedSegmentIndex == 0
        let team   = isWeek ? weekTeam : monthTeam
        
        guard indexPath.section < team.count else { return cell }
        let person = team[indexPath.section]
        
        cell.lblName?.text = NSLocalizedString("walk_team_lblName", comment: "") + " : " + person.name
        
        if isWeek {
            cell.lblAvgSteps?.text    = NSLocalizedString("walk_team_lblWeekAvgSteps", comment: "")      + " : " + person.avgSteps    + " " + NSLocalizedString("walk_team_unitStep", comment: "")
            cell.lblTotalSteps?.text  = NSLocalizedString("walk_team_lblWeekTotalSteps", comment: "")    + " : " + person.totalSteps  + " " + NSLocalizedString("walk_team_unitStep", comment: "")
            cell.lblTotalDistance?.text = NSLocalizedString("walk_team_lblWeekTotalDistances", comment: "") + " : " + person.totalDistance + " " + NSLocalizedString("walk_detail_unitDistance", comment: "")
        } else {
            cell.lblAvgSteps?.text    = NSLocalizedString("walk_team_lblMonthAvgSteps", comment: "")     + " : " + person.avgSteps    + " " + NSLocalizedString("walk_team_unitStep", comment: "")
            cell.lblTotalSteps?.text  = NSLocalizedString("walk_team_lblMonthTotalSteps", comment: "")   + " : " + person.totalSteps  + " " + NSLocalizedString("walk_team_unitStep", comment: "")
            cell.lblTotalDistance?.text = NSLocalizedString("walk_team_lblMonthTotalDistances", comment: "") + " : " + person.totalDistance + " " + NSLocalizedString("walk_detail_unitDistance", comment: "")
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return weekTeam.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
