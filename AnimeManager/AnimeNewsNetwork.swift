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
    
    static let allArticlesEndpoint:String = "/rss.xml"
    
    // article types 
    public struct ANNArticle {
        static let all = "all"
        
        static let newsroom = "newsroom"
        struct NewsRoom{
            let interest = "interest"
            let convention = "convention"
            let news = "news"
            let pressRelease = "press-release"
        }
        
        static let contest = "contest"
        
        static let views = "views"
        struct Views {
            static let views = "views"
            static let editorial = "editorial"
            static let feature = "feature"
            struct Feature {
                static let interview = "interview"
            }
            static let review = "review"
            
            static let column = "column"
            struct Column {
                static let ANNCast = "anncast"
                static let ANNNina = "anime-news-nina"
                static let AstroToy = "astro-toy"
                static let answerman = "answerman"
                static let houseOf1000Manga = "house-of-1000-manga"
                static let encyclopedist = "encyclopedist"
                static let rightTurnOnly = "right-turn-only"
                static let shelfLife = "shelf-life"
                static let mikeToole = "the-mike-toole-show"
                static let xButton = "the-x-button"
            }
        } 
    }
    
    public enum ANNKey:Int{
        case recentlyAddedAnime = 148,
        recentlyAddedManga = 149,
        recentlyAddedCompanies = 151,
        ratingsID = 172
    }
    
    public func allArticles(articleType: String, completion:@escaping (_ articles:[[String:Any]]) -> Void)
    {
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: AnimeNewsNetwork.baseURL + articleType + AnimeNewsNetwork.allArticlesEndpoint, body: nil, headers: nil, completion: { data in
            if let articles = data as? [[String:Any]]{
                completion(articles)
            }
        }) { (error) in
            os_log("%@: Error with HTTP request: %@", log: .default, type: .error, self.description, error.debugDescription)
        }
    }
    
    public func generatedReports(key:ANNKey, completion:@escaping (_ articles:[[String:Any]]) -> Void){
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: AnimeNewsNetwork.baseURL + AnimeNewsNetwork.reportsEndpoint + String(key.rawValue), body: nil, headers: nil, completion: { (data) in
            if let report = data as? [[String:Any]]
            {
                completion(report)
            }
        }) { (error) in
            os_log("%@: Error with HTTP request: %@", log: .default, type: .error, self.description, error.debugDescription)
        }
    }
    

}
