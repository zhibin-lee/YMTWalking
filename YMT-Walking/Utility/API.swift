//
//  API.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/20.
//  Copyright © 2020 animal-g. All rights reserved.
//

import Foundation

let website = "https://vnet.yamaha-motor.com.tw/YMTWalking/"

struct API{
    static let login_loginDetail = website + "Login/LoginDetail"
    static let stepDetail_showStepDetail = website + "StepDetail/ShowStepDetail"
    static let strategyData_showStrategy = website + "StrategyData/ShowStrategy"
    static let upload_uploadData = website + "Upload/UploadData"
    static let groupSteps_showGroupSteps = website + "GroupSteps/ShowGroupSteps"
}
