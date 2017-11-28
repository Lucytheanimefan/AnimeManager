//
//  Requester.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/28/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

class Requester: NSObject {
    
    static let sharedInstance = Requester()
    
    func makeHTTPRequest(method:String, url: String, body: [String: Any]?, completion:@escaping (_ result:[String:Any]) -> Void, errorHandler:@escaping (_ result:[String:Any]) -> Void) {
        #if DEBUG
            os_log("%@: Make Request: %@, %@", self.description, method, url)
        #endif
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = method
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if (body != nil)
        {
            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
        }
        
        #if DEBUG
            os_log("%@: Request: %@", self.description, request.description)
        #endif
        executeHTTPRequest(request: request as URLRequest, completion: completion, errorHandler: errorHandler)
        //executeHTTPRequest(request: request as URLRequest, completion: completion)
        
    }
    
    private func executeHTTPRequest(request: URLRequest, completion:@escaping (_ result:[String:Any]) -> Void, errorHandler:@escaping (_ result:[String:Any]) -> Void =  { error in
        #if DEBUG
            os_log("Execute HTTP request")
        #endif
        if let errorDescription = error["error"] as? String
        {
            os_log("Error making http request: %@", errorDescription)
        }
        }) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            #if DEBUG
                os_log("%@: In HTTP request completion: %@, %@, %@", (data?.description)!, (response?.description)!, error.debugDescription)
            #endif
            
            if (data != nil)
            {
                do{
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]{
                        completion(json)
                    }
                    else
                    {
                        errorHandler(["error": "Failed with json serialization"])
                    }
                }
                catch
                {
                    os_log("%@: Error serializing json: %@, Trying as string.", self.description, error.localizedDescription)
                    if let dataString = String(data:data!, encoding:.utf8)
                    {
                        completion(["string":dataString])
                    }
                    else
                    {
                        errorHandler(["error": "Could not format data as string"])
                        os_log("%@: Could not format data as string", self.description)
                    }
                }
                //completion(data!)
            }
            else if (error != nil)
            {
                errorHandler(["error":error.debugDescription])
                #if DEBUG
                    os_log("%@: Error: %@", self.description, error.debugDescription)
                #endif
            }
            else
            {
                completion(["Result":"No response"])
            }
        })
        task.resume()
    }

}
