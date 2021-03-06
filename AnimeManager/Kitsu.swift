//
//  Kitsu.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class Kitsu: NSObject {
    
    static let baseURL = "https://kitsu.io/api/edge/"
    static let oauthURL = "https://kitsu.io/api/oauth/"
    
    let baseHeaders = ["Accept":"application/vnd.api+json", "Content-Type":"application/vnd.api+json"]
    
    var clientID:String!
    var clientSecret:String!
    init(clientID:String, clientSecret:String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    public func search(attribute:String, value:String, completion:@escaping (_ error:String?, _ result:[String:Any]?) -> Void){
        let url = Kitsu.baseURL + "anime?filter[" + attribute + "]=" + value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: self.baseHeaders) { (data, error) in
            if let json = data as? [String:Any]{
                completion(nil, json)
            }
            else
            {
                os_log("%@: NOT JSON FORMAT", self.description)
                
                completion("NOT JSON FORMAT", nil)
            }
        }
       
    }
    
    public func accessToken()->String{
        let body = ["username":"", "password":"", "grant_type":"password"]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: Kitsu.oauthURL + "token", body: body, headers: nil) { (data, error) in
            
        }
        return ""
    }


}
