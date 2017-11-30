//
//  Funimation.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class Funimation: NSObject {
    
    static let baseURL = "https://prod-api-funimationnow.dadcdigital.com/api/"
    
    var authToken:String!
    var csrftoken:String!
    
    public func authenticate(username:String, password:String, completion:@escaping (_ result:Any) -> Void)
    {
        let url = Funimation.baseURL + "auth/login/"
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: url, body: ["username":username, "password":password], headers: ["User-Agent":"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36", "Territory":"US"], completion: { (data) in
            if let json = data as? [String:Any]
            {
                //os_log("FUNIMATION AUTH RESULTS: %@", json)
                if (json["success"] as? Int == 0)
                {
                    os_log("%@: Error authenticating: %@", self.description, json["error"] as! String)
                }
                else
                {
                    completion(data)
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

}
