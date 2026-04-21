//
//  HealthKitHelper.swift
//  YMT-Walking
//
//  Created by animal-g on 2020/5/7.
//  Copyright © 2020 animal-g. All rights reserved.
//

import Foundation
import HealthKit

class HealthKit
{
    let storage = HKHealthStore()
    
    private enum HealthkitSetupError: Error {
        case notAvailableOnDevice
        case dataTypeNotAvailable
    }
    
    class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
        // step1 : 檢查有沒有Health功能
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, HealthkitSetupError.notAvailableOnDevice)
            return
        }
        
        // step2 : 要跟HealthKit存取啥資料
        guard   let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount),
            let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                completion(false, HealthkitSetupError.dataTypeNotAvailable)
                return
        }
        
        // step3 : 想要取得的資料類型
        let healthKitTypesToRead: Set<HKObjectType> = [stepCount, distanceWalkingRunning, HKObjectType.workoutType()]
        
        //4. Request Authorization
        HKHealthStore().requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            completion(success, error)
        }
    }
    
    func retrieveStepCount(date : Date, completion: @escaping(_ stepRetrieved: Double) -> Void) {
        //   Define the Step Quantity Type
        let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
        
        let sDate = Calendar.current.startOfDay(for:date)
        let eDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        print("YMTWalking:date is ", date)
        print("YMTWalking:sDate is ", sDate)
        print("YMTWalking:eDate is ", eDate)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: sDate, end: eDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: sDate, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                print("YMTWalking : query initial error")
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: sDate, to: eDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let steps = quantity.doubleValue(for: HKUnit.count())
                        
                        //print("YMTWalking Steps = \(steps)")
                        completion(steps)
                        
                    }
                    else {
                        completion(0)
                    }
                }
            }
            
            else {
                print("YMTWalking : can't get result")
            }
            
        }
        
        storage.execute(query)
    }
    
    func retrieveDistanceWalkingRunning(date : Date, completion: @escaping(_ stepRetrieved: Double) -> Void) {
        //   Define the Step Quantity Type
        let distanceWalkingRunning = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)
        
        let sDate = Calendar.current.startOfDay(for:date)
        let eDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
        
        print("YMTWalking:date is ", date)
        print("YMTWalking:sDate is ", sDate)
        print("YMTWalking:eDate is ", eDate)
        
        //  Set the Predicates & Interval
        let predicate = HKQuery.predicateForSamples(withStart: sDate, end: eDate, options: .strictStartDate)
        var interval = DateComponents()
        interval.day = 1
        
        //  Perform the Query
        let query = HKStatisticsCollectionQuery(quantityType: distanceWalkingRunning!, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: sDate, intervalComponents:interval)
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                //  Something went Wrong
                print("YMTWalking : query initial error")
                return
            }
            
            if let myResults = results{
                myResults.enumerateStatistics(from: sDate, to: eDate) {
                    statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        
                        let distance = quantity.doubleValue(for: HKUnit.meterUnit(with: .kilo))
                        
                        //print("YMTWalking Steps = \(steps)")
                        completion(distance)
                        
                    }
                    else {
                        completion(0)
                    }
                }
            }
            
            else {
                print("YMTWalking : can't get result")
            }
            
        }
        
        storage.execute(query)
    }
}
