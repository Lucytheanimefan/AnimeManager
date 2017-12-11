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
    
    public static let sharedInstance = AnimeNewsNetwork()
    
    static let baseURL:String = "https://www.animenewsnetwork.com/"
    
    static let reportsEndpoint:String = "encyclopedia/reports.xml?id="
    
    static let allArticlesEndpoint:String = "/rss.xml"
    
    // article types 
    public struct ANNArticle {
        public static let all = "all"
        
        public static let newsroom = "newsroom"
        public struct NewsRoom{
            public static let interest = "interest"
            public static let convention = "convention"
            public static let news = "news"
            public static let pressRelease = "press-release"
        }
        
        public static let contest = "contest"
        
        public static let views = "views"
        public struct Views {
            public static let views = "views"
            public static let editorial = "editorial"
            public static let feature = "feature"
            public struct Feature {
                static let interview = "interview"
            }
            public static let review = "review"
            
            public static let column = "column"
            public struct Column {
                public static let ANNCast = "anncast"
                public static let ANNNina = "anime-news-nina"
                public static let AstroToy = "astro-toy"
                public static let answerman = "answerman"
                public static let houseOf1000Manga = "house-of-1000-manga"
                public static let encyclopedist = "encyclopedist"
                public static let rightTurnOnly = "right-turn-only"
                public static let shelfLife = "shelf-life"
                public static let mikeToole = "the-mike-toole-show"
                public static let xButton = "the-x-button"
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
