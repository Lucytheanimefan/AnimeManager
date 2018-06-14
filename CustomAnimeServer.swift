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
//    var baseURL = "http://127.0.0.1:5000/"
//    #else
    var baseURL = "https://lucys-anime-server.herokuapp.com/"
//    #endif
    
    let headers = ["Content-Type": "application/json",
                   "Accept": "application/json"]
    
    convenience init(baseURL:String) {
        self.init()
        self.baseURL = baseURL
    }
    
    // Body: title, anime_id, review
    public func addReview(title:String, animeID:String, review:String, completion:@escaping (_ response:String) -> Void){
        let body = ["title":title, "anime_id":animeID, "review":review]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: "\(baseURL)addReview", body: body, headers: nil) { (data, error) in
            if let error = error{
                os_log("%@: Error: %@", self.description, error)
            }
        }
    }
    
    public func updateReview(title:String, animeID:String, review:String, completion:@escaping (_ response:String) -> Void, errorcompletion:@escaping () -> Void){
        let body = ["title":title, "anime_id":animeID, "review":review]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: "\(baseURL)updateReview", body: body, headers: self.headers) {(response, error) in
            if let resp = response as? [String:Any], let res = resp["string"] as? String{
                completion(res)
            }
        }
    }
    
    public func getReview(animeID:String? ,completion:@escaping (_ response:[[String:Any]]) -> Void){
        var url:String! = "\(baseURL)reviews"
        if (animeID != nil)
        {
            url.append("?anime_id=\(animeID!)")
        }
        Requester.sharedInstance.makeHTTPRequest(method: "GET", url: url, body: nil, headers: self.headers) { (data, error) in
            //print(data)
            if let json = data as? [String:Any]
            {
                
                //completion(json)
                
                if let resp = json["string"] as? String{
                    let fixedResp = resp.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "\"\"", with: "")
                    os_log("%@: Fixed response: %@", self.description, fixedResp)
                    
                    
                    let strData = fixedResp.data(using: .utf8)
                    do
                    {
                        let response: AnyObject? = try JSONSerialization.jsonObject(with: strData!, options: .allowFragments) as AnyObject
                        
                        if let decoded = response as? [[String:Any]]{
                            os_log("%@: Decoded: %@", self.description, decoded)
                            completion(decoded)
                        }
                        else
                        {
                            os_log("%@: Decoded not correct form: %@", self.description, response.debugDescription)
                        }
                    }
                    catch
                    {
                        os_log("%@: Error: %@", self.description, error.localizedDescription)
                    }
                    
                    //completion(resp)
                }
            }
        }
    }

}
