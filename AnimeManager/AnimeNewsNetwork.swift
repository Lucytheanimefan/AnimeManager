//
//  AnimeNewsNetwork.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/30/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

public class AnimeNewsNetwork: NSObject {
    
    static let sharedInstance = AnimeNewsNetwork()
    
    static let baseURL:String = "https://www.animenewsnetwork.com/"
    
    static let reportsEndpoint:String = "encyclopedia/reports.xml?id="
    
    static let allArticlesEndpoint:String = "all/rss.xml"
    
    public enum ANNKeys:Int{
        case recentlyAddedAnime = 148,
        recentlyAddedManga = 149,
        recentlyAddedCompanies = 151,
        ratingsID = 172
    }
    
    public func allArticles(completion:@escaping (_ articles:[[String:Any]]) -> Void)
    {
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: AnimeNewsNetwork.baseURL + AnimeNewsNetwork.allArticlesEndpoint, body: nil, headers: nil, completion: { data in
            if let articles = data as? [[String:Any]]{
                completion(articles)
            }
        }) { (error) in
            os_log("%@: Error with HTTP request: %@", log: .default, type: .error, self.description, error.debugDescription)
        }
    }
    

}
