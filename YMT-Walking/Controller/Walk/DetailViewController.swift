//
//  DetailViewController.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/14.
//  Copyright © 2020 animal-g. All rights reserved.
//

import UIKit
import Alamofire
import JGProgressHUD

class DetailViewController: UIViewController {
    
    @IBOutlet weak var btnRefresh: UIBarButtonItem!
    @IBOutlet weak var lblNotice: UILabel!
    @IBOutlet weak var tbvStepDetail: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStyle()
        tbvStepDetail.dataSource = self
        tbvStepDetail.delegate = self
        tbvStepDetail.backgroundColor = UIColor(named: "color_yamaha_grey")
        tbvStepDetail.allowsSelection = false
        tbvStepDetail.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "DetailCell")
        // Do any additional setup after loading the view.
        
        // 單指輕點
        let singleFinger = UITapGestureRecognizer(target:self,action:#selector(singleTap))
        // 點幾下才觸發 設置 2 時 則是要點兩下才會觸發 依此類推
        singleFinger.numberOfTapsRequired = 2
        self.lblNotice.isUserInteractionEnabled = true
        self.lblNotice.addGestureRecognizer(singleFinger)
    }
    
    func setStyle(){
        self.title = NSLocalizedString("walk_detail_title", comment: "")
        self.lblNotice.text = NSLocalizedString("walk_detail_lblNotice", comment: "")
    }
    
    @objc func singleTap(recognizer:UITapGestureRecognizer){
        print("1")
        guard let Url = URL(string: "https://vnet.yamaha-motor.com.tw/YMTWalkingWeb/redirect.aspx?q="+id) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(Url) {
            UIApplication.shared.open(Url, completionHandler: { (success) in
                //print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    @IBAction func btnRefreshOnclick(_ sender: Any) {
        // get detail information
        
        progressHUD.show(in: self.view)
        
        let params : [String: String] = ["EmpID" : id]
        
        AF.request(API.stepDetail_showStepDetail, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
                case .success(let value):
                steps = []
                if let result = value as? [String: AnyObject] {
                    let rcrm: [String : Any]? = result["rcrm"]as? [String : Any]
                    if(rcrm!["RC"] as? Int == 1){
                        let datalist : [[String : Any]]? = result["results"]?["Record_Data"] as? [[String : Any]]
                        for data in datalist! {
                            let detail = Detail(walkingDate: data["date"] as! String, stepsCount: data["step"] as! String, distanceWR: data["distance"] as! String)
                            steps.append(detail)
                        }
                        self.tbvStepDetail.reloadData()
                        progressHUD.dismiss(animated: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DetailViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailCell
        cell.lblDate.text = steps[indexPath.row].walkingDate
        cell.lblSteps.text = steps[indexPath.row].stepsCount + NSLocalizedString("walk_detail_unitStep", comment: "")
        cell.lblDistance.text = steps[indexPath.row].distanceWR + NSLocalizedString("walk_detail_unitDistance", comment: "")
        return cell
    }
}
