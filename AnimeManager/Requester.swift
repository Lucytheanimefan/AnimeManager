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
    
    func makeHTTPRequest(method:String, url: String, body: [String: Any]?, headers:[String:String]?, completion:@escaping (_ result:Any) -> Void, errorHandler:@escaping (_ result:[String:Any]) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = method
        
        //request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        headers?.forEach({ (arg) in
            let (key, value) = arg
            request.addValue(value, forHTTPHeaderField: key)
        })
        
        if (body != nil)
        {
            do {
                os_log("%@: Set body: %@", self.description, body!)
                request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: [])
//                else
//                {
//                    os_log("%@: Error serializing body %@", self.description, body!)
//                }
            }
            catch
            {
                os_log("%@: Error serializing body %@", self.description, body!)
            }
        }
        
        #if DEBUG
            os_log("%@: Request: %@", self.description, request.description)
            
        #endif
        executeHTTPRequest(request: request as URLRequest, completion: completion, errorHandler: errorHandler)
        
        //executeHTTPRequest(request: request as URLRequest, completion: completion)
        
    }
    
    private func executeHTTPRequest(request: URLRequest, completion:@escaping (_ result:Any) -> Void, errorHandler:@escaping (_ result:[String:Any]) -> Void =  { error in
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
                //os_log("%@: In HTTP request completion: %@, %@, %@", (data?.description)!, (response?.description)!, error.debugDescription)
            #endif
            
            if (data != nil)
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    completion(json)
                    
//                    else
//                    {
//                        if let dataString = String(data:data!, encoding:.utf8)
//                        {
//                            completion(["string":dataString])
//                        }
//                        else
//                        {
//                            errorHandler(["error": "Failed with json serialization"])
//                        }
//                    }
                }
                catch
                {
                    if let dataString = String(data:data!, encoding:.utf8)
                    {
                        completion(["string":dataString])
                    }
                    else
                    {
                        errorHandler(["error": "Failed with json serialization"])
                        os_log("%@: Error seh  rializing json: %@, Trying as string.", self.description, error.localizedDescription)
                        
                        errorHandler(["error": error.localizedDescription])
                    }
//                    os_log("%@: Error seh  rializing json: %@, Trying as string.", self.description, error.localizedDescription)
//
//                    errorHandler(["error": error.localizedDescription])
                }
                completion(data!)
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
