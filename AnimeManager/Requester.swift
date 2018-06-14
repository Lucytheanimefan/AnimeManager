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
    
    var xmlElementName:String!
    var xmlChunk:[String:Any]! = [String:Any]()
    var xmlChunks:[[String:Any]]! = [[String:Any]]()
    var xmlCompletion:(([[String:Any]])->Void)!
    
    let validXMLKeys = ["title", "description", "guid", "link", "pubDate", "category"]
    
    override init() {
        super.init()
    }
    
    func makeHTTPRequest(method:String, url: String, body: Any?, headers:[String:String]?, completion:@escaping (_ result:Any, _ error:String?) -> Void) {
        
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL)
        request.httpMethod = method

        headers?.forEach({ (arg) in
            let (key, value) = arg
            request.addValue(value, forHTTPHeaderField: key)
        })
        
        if (body != nil)
        {
            if let body = body as? [String: Any]{
                do {
                    os_log("%@: Set body: %@", self.description, body)
                    request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                }
                catch
                {
                    os_log("%@: Error serializing body %@", self.description, body)
                }
            }
            else if let body = body as? Data {
                request.httpBody = body
            }
        }
        
        #if DEBUG
            os_log("%@: Request: %@", self.description, request.description)
        #endif
        
        executeHTTPRequest(request: request as URLRequest, completion: completion)
        
        
    }
    
    private func executeHTTPRequest(request: URLRequest, xmlCompletion:(([[String:Any]])->Void)? = nil, completion:@escaping (_ result:Any, _ error:String?) -> Void) {
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            
            #if DEBUG
                os_log("%@: In HTTP request completion: %@, %@, %@", (data?.description)!, (response?.description)!, error.debugDescription)
            #endif
            
            if (data != nil)
            {
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    completion(json, nil)
                }
                catch
                {
                    var xmlSuccess:Bool!
                    let parser = XMLParser(data: data!)
                    
                    parser.delegate = self
                    if let comp = xmlCompletion{
                        self.xmlCompletion = comp
                    }
                    xmlSuccess = parser.parse()
                    
                    if (xmlSuccess){
                        return
                    }
                    
                    if let dataString = String(data:data!, encoding:.utf8), xmlSuccess == false
                    {
                        completion(["string":dataString], nil)
                    }
                    else
                    {
                        completion("Failed with json serialization: \(error.localizedDescription)", nil)
                        os_log("%@: Error serializing json: %@, Trying as string.", self.description, error.localizedDescription)
                    }
                }
                //completion(data!)
            }
            else if (error != nil)
            {
                completion(error?.localizedDescription, nil)
                #if DEBUG
                    os_log("%@: Error: %@", self.description, error.debugDescription)
                #endif
            }
            else
            {
                completion("Result is nil", nil)
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
        if (elementName == "item" || elementName == "user"){
            // Handle chunk by chunk
            // append the chunk
            xmlChunks.append(xmlChunk)
            //self.xmlCompletion(xmlChunk)
            xmlChunk = [String:Any]()
        }
        // Finished 1 chunk of data, time to do something with it
        if (elementName == "rss" || elementName == "report" || elementName == "user" /*mal user verification*/){
            //os_log("%@: CHUNK: %@", self.className, xmlChunk)
            self.xmlCompletion(xmlChunks)
            xmlChunks = [[String:Any]]()
            
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }
    
}
