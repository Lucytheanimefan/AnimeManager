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
    
    static let baseURL = "https://graphql.anilist.co/api/v2/"
    
    let authEndpoint = "oauth/token"
    
    var displayName:String!
    var clientID:String! 
    var clientSecret:String!
    
    var accessToken:String!
    var expiration:Int!
    var lastAuthed:Date!
    
    lazy var auth = {
        return "?access_token=\(self.accessToken)"
    }()
    
    let headers = ["Content-Type": "application/json",
                   "Accept": "application/json"]
    
    init(clientID:String, clientSecret:String) {
        super.init()
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    convenience init(displayName:String, clientID:String, clientSecret:String) {
        self.init(clientID: clientID, clientSecret: clientSecret)
        self.displayName = displayName
    }
    
    // MARK: User
    public func authenticate(completion:@escaping (_ accessToken:String) -> Void){
        //let params:[String:Any] = ["grant_type":"client_credentials", "client_id": self.clientID, "client_secret": self.clientSecret]
        if self.checkToken(){
            completion(self.accessToken)
            return
        }
        let body = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: AniList.baseURL + authEndpoint, body: body.data(using: .utf8), headers: /*self.headers*/nil, completion: { (data) in
            
            
            if let json = data as? [String:Any]
            {
                os_log("%@: Returned data: %@",self.description, json)
                self.accessToken = json["access_token"] as! String
                self.expiration = json["expires_in"] as! Int
                self.lastAuthed = Date()
                completion(self.accessToken)
            }
        }) { (error) in
            os_log("%@: Error", log: .default, type: .error, self.description, error)
        }
    }
    
    public func user(completion:@escaping (_ userInfo:[String:Any]) -> Void)
    {
        guard self.checkToken() else {
            os_log("%@: No access token, can't proceed with call", log: .default, type: .error, self.description)
            return
        }
        
        let url = AniList.baseURL + "user/\(self.clientID)\(self.auth)"
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: self.headers, completion: { (data) in
            if let json = data as? [String:Any]
            {
                os_log("%@: Returned data: %@", self.description, json)
                completion(json)
            }
        }) { (error) in
            os_log("%@: Error", log: .default, type: .error, self.description, error)
        }
    }
    
    
    private func checkToken() -> Bool{
        return (self.accessToken != nil && self.expiration != nil && self.lastAuthed != nil &&
            (self.lastAuthed.addingTimeInterval(31536000) > Date()))
    }
    
}
