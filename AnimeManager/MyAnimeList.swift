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
    
    public enum Status : Int {
        case currentlyWatching = 1, completed, onHold, dropped, planToWatch, all
    }
    
    init(username:String, password:String?) {
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
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, completion: { (result) in
            if let animeList = result as? [[String:Any]]{
                completion(animeList)
            }
            else
            {
                print(result)
                errorHandler(["error":"Anime list not in correct format"])
                //os_log("%@: Result: %@", self.description, result.description)
                //completion(result)
            }
        }) { (error) -> Void in
            errorHandler(error)
        }
    }
    
    public func getCurrentlyWatchingAnime(completion:@escaping (_ animeList:[[String:Any]]) -> Void, errorHandler:@escaping (_ error:[String:Any]) -> Void) -> Void
    {
        let url = MyAnimeList.baseURL + "animelist/" + self.username + "/load.json?status=1"
    }
}
