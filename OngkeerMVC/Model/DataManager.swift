//
//  DataManager.swift
//  OngkeerMVC
//
//  Created by Nanda Mochammad on 19/10/19.
//  Copyright © 2019 Nanda Mochammad. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class DataManager{
    
    static let shared = DataManager()
    
    private init (){}
    
    //object CoreData
    var provinceCoreData : [PROVINCE] = []
    var cityCoreData : [CITY] = []
    
    let baseURL = "https://api.rajaongkir.com/starter"
    private let API_KEY = "0df6d5bf733214af6c6644eb8717c92c"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var provinceData : [province] = []
    var cityData : [city] = []
    
    var choosenCityOrigin = CITY()
    var choosenCityDestination = CITY()
    
    var cityOriginFlag = 0
    var cityDestinationFlag = 0
    
    var homePage = HomePageViewController()
    
    func requestProvince(){
        print("Request Province Started . . .")
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "key": API_KEY
        ]
        
        Alamofire.request("\(baseURL)/province", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responses) in
            print("Request Done . . .")
            if let value = responses.result.value as! [String:Any]?{
                let JSONResult = JSON(value)
                if JSONResult["rajaongkir"]["status"]["code"] == 400{
                    print("APIKEY Not Found")
                }else{
                    print(JSONResult)
                    for (_, subJson) in JSONResult["rajaongkir"]["results"]{
                        let dataProv = province.init(province_id: subJson["province_id"].stringValue,
                                                         province_name: subJson["province"].stringValue)
                        self.provinceData.append(dataProv)
                        
                        UserDefaults.standard.set(true, forKey: "loadDataProvince")
                        
                    }
                    self.saveToCoreData(data: "Province")
                    
                }
            }else{
                print("Connection Timed Out")
            }
        }
    }
    
    func requestCity(){
        print("Request Province Started . . .")
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "key": API_KEY
        ]
        
        Alamofire.request("\(baseURL)/city", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (responses) in
            print("Request Done . . .")
            if let value = responses.result.value as! [String:Any]?{
                let JSONResult = JSON(value)
                if JSONResult["rajaongkir"]["status"]["code"] == 400{
                    print("APIKEY Not Found")
                }else{
                    for (_, subJson) in JSONResult["rajaongkir"]["results"]{
                        let dataCity = city.init(city_id: subJson["city_id"].stringValue,
                                                 province_id: subJson["province_id"].stringValue,
                                                 province_name: subJson["province"].stringValue,
                                                 type: subJson["type"].stringValue,
                                                 city_name: subJson["city_name"].stringValue,
                                                 postal_code: subJson["postal_code"].stringValue)
                        self.cityData.append(dataCity)
                        
                        UserDefaults.standard.set(true, forKey: "loadDataCity")

                    }
                    self.saveToCoreData(data: "City")

                }
            }else{
                print("Connection Timed Out")
            }
        }
    }
    
    func saveToCoreData(data: String){
        if data == "Province"{
            provinceData.forEach { (dataProv) in
                let province = PROVINCE(context: self.context)
                province.province_id = dataProv.province_id
                province.province_name = dataProv.province_name
                
                provinceCoreData.append(province)
                
                do {
                    try context.save()
                } catch  {
                    print("Error save province guys, ", error)
                }
            }
        }else{
            cityData.forEach { (dataCity) in
                let city = CITY(context: self.context)
                city.province_id = dataCity.province_id
                city.city_name = dataCity.city_name
                city.city_id = dataCity.city_id
                city.province_name = dataCity.province_name
                city.type = dataCity.type
                city.postal_code = dataCity.postal_code
                
                cityCoreData.append(city)
                
                do {
                    try context.save()
                } catch  {
                    print("Error save city guys, ", error)
                }
            }
        }
    }
    
    func loadFromCoreData(completion: @escaping([PROVINCE], [CITY]) -> Void){
        print("Load From Core Data . . .")
        let requestProvince : NSFetchRequest = PROVINCE.fetchRequest()
        let requestCity : NSFetchRequest = CITY.fetchRequest()
        
        do {
            provinceCoreData = try context.fetch(requestProvince)
            
            cityCoreData = try context.fetch(requestCity)
            completion(provinceCoreData, cityCoreData)
            
            print("Load Done . . .")
        } catch  {
            print("Error cuy, benerin dong!, ", error)
            completion([], [])
        }
    }
    
    func requestCost(origin: String, destination: String, weight: String, courier: String, completion: @escaping(String) -> Void){
        print("Request Cost Started . . .")
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "key": API_KEY
        ]
        
        let parameters = [
            "origin": origin,
            "destination": destination,
            "weight": weight,
            "courier": courier
        ]
        
        
        Alamofire.request("\(baseURL)/cost", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (responses) in
            print("Request Done . . .")
            if let value = responses.result.value as! [String:Any]?{
                let JSONResult = JSON(value)
                if JSONResult["rajaongkir"]["status"]["code"] == 400{
                    print("APIKEY Not Found")
                }else{
                    for (_, subJson) in JSONResult["rajaongkir"]["results"]{
                        let total = subJson["costs"][0].stringValue
                        
                        completion(total)
                        

                    }

                }
            }else{
                print("Connection Timed Out")
            }
        }
    }
}

struct province{
    var province_id : String
    var province_name : String
}

struct city{
    var city_id : String
    var province_id : String
    var province_name : String
    var type : String
    var city_name : String
    var postal_code : String
}
