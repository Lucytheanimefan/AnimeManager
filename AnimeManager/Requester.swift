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
    
    private var _parser:XMLParser!
//    var parser:XMLParser {
//        get {
//            return self._parser
//        }
//        set {
//            self._parser = newValue
//            self._parser.delegate = self
//        }
//    }
    
    var xmlElementName:String!
    var xmlChunk:[String:Any]! = [String:Any]()
    var xmlChunks:[[String:Any]]! = [[String:Any]]()
    var xmlCompletion:(([[String:Any]])->Void)!
    
    let validXMLKeys = ["title", "description", "guid", "link", "pubDate", "category"]
    
    override init() {
        super.init()
    }
    
    func makeHTTPRequest(method:String, url: String, body: [String: Any]?, headers:[String:String]?, completion:@escaping (_ result:Any) -> Void, errorHandler:@escaping (_ result:[String:Any]) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = method
        
        headers?.forEach({ (arg) in
            let (key, value) = arg
            request.addValue(value, forHTTPHeaderField: key)
        })
        
        if (body != nil)
        {
            do {
                os_log("%@: Set body: %@", self.description, body!)
                request.httpBody = try JSONSerialization.data(withJSONObject: body!, options: [])
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
                }
                catch
                {
                    var xmlSuccess:Bool!
                    // Try XML format (ANN)
                    if let parser = XMLParser(data: data!) as? XMLParser{
                        parser.delegate = self
                        self.xmlCompletion = completion
                        xmlSuccess = parser.parse()
                        
                        if (xmlSuccess){
                            return
                        }
                    }
                    
                    
                    if let dataString = String(data:data!, encoding:.utf8), xmlSuccess == false
                    {
                        completion(["string":dataString])
                    }
                    else
                    {
                        errorHandler(["error": "Failed with json serialization"])
                        os_log("%@: Error seh  rializing json: %@, Trying as string.", self.description, error.localizedDescription)
                        
                        errorHandler(["error": error.localizedDescription])
                    }
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

extension Requester:XMLParserDelegate{
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        xmlElementName = elementName
        xmlChunk[xmlElementName] = ""
        if let url = attributeDict["href"]{
            xmlChunk["href"] = url
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //        if (xmlElementName == "anime" || xmlElementName == "manga" || xmlElementName == "company"){
        //            xmlElementName = "title"
        //        }
        if (xmlChunk[xmlElementName] == nil){
            xmlChunk[xmlElementName] = ""
        }
        
        xmlChunk[xmlElementName] = xmlChunk[xmlElementName] as! String + string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "item"){
            // Handle chunk by chunk
            // append the chunk
            xmlChunks.append(xmlChunk)
            //self.xmlCompletion(xmlChunk)
            xmlChunk = [String:Any]()
        }
        // Finished 1 chunk of data, time to do something with it
        if (elementName == "rss"){
            //os_log("%@: CHUNK: %@", self.className, xmlChunk)
            self.xmlCompletion(xmlChunks)
            xmlChunks = [[String:Any]]()
            
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }
    
}
