//
//  CrunchyRoll.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit

public class CrunchyRoll: NSObject {
    
    static let baseURL = "https://api.crunchyroll.com/"
    
    let headers = ["Host": "api.crunchyroll.com",
    "Accept-Encoding": "gzip, deflate",
    "Accept": "*/*",
    "Content-Type": "application/x-www-form-urlencoded",
    "User-Agent":"Mozilla/5.0 (iPhone; iPhone OS 8.3.0; en)"]
    
    public func login(){
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: baseURL(param: "login"), body: nil, headers: self.headers, completion: { (data) in
            print(data)
        }) { (error) in
            print(error)
        }
    }
    
    private func baseURL(param:String) -> String{
       return CrunchyRoll.baseURL + param + ".0.json"
    }

}
