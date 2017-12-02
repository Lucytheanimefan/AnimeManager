//
//  MyAnimeList.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class MyAnimeList: NSObject {
    
    //public static let sharedInstance = MyAnimeList()
    
    static let baseURL = "https://myanimelist.net/" //animelist/{}/load.json'.format(username)"
    
    var username:String!
    var password:String!
    
    lazy var authHeader:String? = {
        if (self.password != nil && self.username != nil)
        {
            let rawHeader = String(format: "%@:%@", self.username, self.password)//self.username + ":" + self.password
            let loginData = rawHeader.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            return "Basic \(base64LoginString)"
        }
        return nil
    }()
    
    public enum Status : Int {
        case currentlyWatching=1, completed, onHold, dropped, planToWatch=6, all=7
    }
    
    public init(username:String, password:String?) {
        super.init()
        self.username = username
        if (password != nil)
        {
            self.password = password
        }
    }
    
    // Get the entire anime list
    public func getAnimeList(status:Status, completion:@escaping (_ animeList:[[String:Any]]) -> Void, errorHandler:@escaping (_ error:[String:Any]) -> Void) -> Void
    {
        let url = MyAnimeList.baseURL + "animelist/" + self.username + "/load.json?status=" + String(status.rawValue)
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: nil, completion: { (result) in
            if let animeList = result as? [[String:Any]]{
                completion(animeList)
            }
            else
            {
                errorHandler(["error":"Anime list not in correct format"])
            }
        }) { (error) -> Void in
            errorHandler(error)
        }
    }
    
    public func verifyAccount(completion:@escaping (_ result:[String:Any]) -> Void){
        let url = MyAnimeList.baseURL + "api/account/verify_credentials.xml"
        
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: ["Authorization":self.authHeader!], completion: { (data) in
            print(data)
            if let json = data as? [String:Any]{
                completion(json)
            }
        }) { (error) in
            os_log("%@: Error: %@", type:.error,self.description, error)
        }
    }
    
    public func searchMAL(query:String, completion:@escaping (_ result:[String:Any]) -> Void)
    {
        let url = MyAnimeList.baseURL + "api/anime/search.xml?q=" + query.replacingOccurrences(of: " ", with: "+")
        
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: ["Authorization":self.authHeader!], completion: { (result) in
            if let searchResult = result as? [String:Any]{
                completion(searchResult)
            }
            else
            {
                
            }
        }) { (error) -> Void in
        
        }
        
    }

}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
