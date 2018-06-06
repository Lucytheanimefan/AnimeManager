//
//  MyAnimeList.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log
import Foundation

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
    
    public static let statusKey:[Int:String] = [Status.currentlyWatching.rawValue:"Currently Watching", Status.completed.rawValue:"Completed", Status.onHold.rawValue: "On Hold", Status.dropped.rawValue: "Dropped", Status.planToWatch.rawValue: "Plan to Watch", Status.all.rawValue: "All"]
    
    public init(username:String, password:String?) {
        super.init()
        self.username = username
        if (password != nil)
        {
            self.password = password
        }
    }
    
    // Get the entire anime list
    public func getAnimeList(status:Status, completion:@escaping (_ animeList:[[String:Any]]) -> Void) -> Void
    {
        let url = MyAnimeList.baseURL + "animelist/" + self.username + "/load.json?status=" + String(status.rawValue)
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: nil, completion: { (result, error) in
            
            guard error == nil else {
                return
            }
            
            if let animeList = result as? [[String:Any]]{
                completion(animeList)
            }
            else
            {
                return
            }
        })
    }
    
    public func verifyAccount(completion:@escaping (_ result:[String:Any]) -> Void){
        let url = MyAnimeList.baseURL + "api/account/verify_credentials.xml"
        
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: ["Authorization":self.authHeader!], completion: { (data, error) in
            guard error == nil else {
                return
            }
            if let json = data as? [String:Any]{
                completion(json)
            }
        })
    }
    
    public func searchMAL(query:String, completion:@escaping (_ result:[String:Any]) -> Void)
    {
        let url = MyAnimeList.baseURL + "api/anime/search.xml?q=" + query.replacingOccurrences(of: " ", with: "+")
        
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: ["Authorization":self.authHeader!], completion: { (result, error) in
            
            guard error == nil else {
                return
            }
            
            if let searchResult = result as? [String:Any]{
                completion(searchResult)
            }
            else
            {
                
            }
        })
        
    }

// Anime values:
//    episode. int
//    status. int OR string. 1/watching, 2/completed, 3/onhold, 4/dropped, 6/plantowatch
//    score. int
//    storage_type. int (will be updated to accomodate strings soon)
//    storage_value. float
//    times_rewatched. int
//    rewatch_value. int
//    date_start. date. mmddyyyy
//    date_finish. date. mmddyyyy
//    priority. int
//    enable_discussion. int. 1=enable, 0=disable
//    enable_rewatching. int. 1=enable, 0=disable
//    comments. string
//    tags. string. tags separated by commas
    public func updateMALEntry(id:String, parameters:[String:Any], completion:@escaping (_ result:[String:Any]) -> Void){
        let url = MyAnimeList.baseURL + "api/animelist/update/\(id).xml"
        let body = ["data":jsonToXML(json: parameters)]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: url, body: body, headers: ["Authorization":self.authHeader!], completion: { (data, error) in
            
            guard error == nil else {
                return
            }
            
            //print(data)
            if let result = data as? [String:Any]{
                completion(result)
            }
        })
    }
    
    public func seasonalAnime(season:Int, completion:@escaping (_ anime:[String:Any]) -> Void){
        self.searchMAL(query: "Not yet aired", completion: completion)
    }
    
    private func jsonToXML(json:[String:Any]) -> String{
        var xml = ("<?xml version='1' encoding='UTF-8'?><entry>")
        json.forEach { (keyValuePair) in
            let (key, value) = keyValuePair
            xml += "<\(key)>\(value)</\(key)>"
        }
        xml += "</entry>"
        return xml
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
