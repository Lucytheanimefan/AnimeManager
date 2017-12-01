//
//  AniList.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/30/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

class AniList: NSObject {
    
    static let baseURL = "https://graphql.anilist.co/api/"
    
    let authEndpoint = "v2/oauth/token"
    
    var clientID:String! // This is the same as the client
    var clientSecret:String!
    
    var accessToken:String!
    
    init(clientID:String, clientSecret:String) {
        super.init()
        
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func authenticate(completion:@escaping (_ accessToken:String) -> Void){
        //let params:[String:Any] = ["grant_type":"client_credentials", "client_id": self.clientID, "client_secret": self.clientSecret]
        
        let body = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: AniList.baseURL + authEndpoint, body: body.data(using: .utf8), headers: nil, completion: { (data) in
            
            
            if let json = data as? [String:Any]
            {
                os_log("%@: Returned data: %@",self.description, json)
                self.accessToken = json["access_token"] as! String
                completion(self.accessToken)
            }
        }) { (error) in
            os_log("%@: Error", log: .default, type: .error, self.description, error)
        }
        
    }

}
