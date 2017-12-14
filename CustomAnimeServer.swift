//
//  CustomAnimeServer.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 12/14/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class CustomAnimeServer: NSObject {
    
//    #if DEBUG
//    var baseURL = "http://0.0.0.0:5000/"
//    #else
    var baseURL = "https://lucys-anime-server.herokuapp.com/"
    //#endif
    
    
    
    convenience init(baseURL:String) {
        self.init()
        self.baseURL = baseURL
    }
    
    // Body: title, anime_id, review
    public func addReview(title:String, animeID:String, review:String, completion:@escaping (_ response:String) -> Void){
        let body = ["title":title, "anime_id":animeID, "review":review]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: "\(baseURL)addReview", body: body, headers: nil, completion: completion as! (Any) -> Void, errorHandler: { (error) in
            os_log("%@: Error: %@", self.description, error)
        })
    }
    
    public func updateReview(title:String, animeID:String, review:String, completion:@escaping (_ response:String) -> Void){
        let body = ["title":title, "anime_id":animeID, "review":review]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: "\(baseURL)updateReview", body: body, headers: nil, completion: {(response) in
            print(response)
            if let resp = response as? [String:Any], let res = resp["string"] as? String{
                completion(res)
            }
        }, errorHandler: { (error) in
            os_log("%@: Error: %@", self.description, error)
        })
    }

}
