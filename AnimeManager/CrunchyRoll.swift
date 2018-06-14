//
//  CrunchyRoll.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class CrunchyRoll: NSObject {
    
    static let baseURL = "https://api.crunchyroll.com/"
    
    let headers = ["Host": "api.crunchyroll.com",
    "Accept-Encoding": "gzip, deflate",
    "Accept": "*/*",
    "Content-Type": "application/x-www-form-urlencoded",
    "User-Agent":"Mozilla/5.0 (iPhone; iPhone OS 8.3.0; en_US)"]
    
    static let APIVersion = "2313.8"
    static let defaultLocale = "en_US"
    
    //var defaultBody = ["version":CrunchyRoll.APIVersion, "locale":CrunchyRoll.defaultLocale]
    
    public func login(username:String, password:String, completion:@escaping (_ result:[String:Any]) -> Void){
        let body:[String:String] = ["account":username, "password":password, "version":CrunchyRoll.APIVersion, "locale":CrunchyRoll.defaultLocale]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: baseURL(param: "login"), body: body, headers: self.headers) { (data, error) in
            //print(data)
            if let json = data as? [String:Any]{
                if let errorCode = json["error"] as? Int{
                    if (errorCode > 0)
                    {
                        os_log("%@: Login error: %@ : %@", self.description, json["code"] as! String,json["message"] as! String)
                    }
                }
                else
                {
                    completion(json)
                }
            }
        }
    }
    
    private func baseURL(param:String) -> String{
       return CrunchyRoll.baseURL + "\(param).0.json"
    }

}
