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
    
    public static let sharedInstance = MyAnimeList()
    
    static let baseURL = "https://myanimelist.net/" //animelist/{}/load.json'.format(username)"
    
    public func getAnimeList(username:String, completion:@escaping (_ animeList:[[String:Any]]) -> Void, errorHandler:@escaping (_ error:[String:Any]) -> Void) -> Void
    {
        let url = MyAnimeList.baseURL + "animelist/" + username + "/load.json"
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
}
