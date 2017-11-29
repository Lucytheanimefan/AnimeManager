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
    
    let baseHeaders = ["Accept":"application/vnd.api+json", "Content-Type":"application/vnd.api+json"]
    
    public func search(attribute:String, value:String, completion:@escaping (_ result:[String:Any]) -> Void){
        let url = Kitsu.baseURL + "anime?filter[" + attribute + "]=" + value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: self.baseHeaders, completion: { (data) in
            if let json = data as? [String:Any]{
                completion(json)
            }
            else
            {
                os_log("%@: NOT JSON FORMAT", self.description)
                print(data)
            }
        }) { (error) in
            print(error)
        }
    }


}
