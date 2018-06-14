//
//  AniList.swift
//  AnimeManager
//
//  Created by Lucy Zhang on 11/30/17.
//  Copyright © 2017 Lucy Zhang. All rights reserved.
//

import UIKit
import os.log

class AniList: NSObject {
    
    static let baseURL = "https://graphql.anilist.co/"
    
    //static let graphURL = "https://graphql.anilist.co"
    
    let authEndpoint = "api/v2/oauth/token"
    
    var displayName:String!
    var clientID:String! 
    var clientSecret:String!
    
    var accessToken:String!
    var expiration:Int!
    var lastAuthed:Date!
    
    lazy var auth = {
        return "?access_token=\(self.accessToken!)"
    }()
    
    let headers = ["Content-Type": "application/json",
                   "Accept": "application/json"]
    
    init(clientID:String, clientSecret:String) {
        super.init()
        self.clientID = clientID
        self.clientSecret = clientSecret
        
        #if DEBUG
            self.accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjFkYjBhZmYwY2IyNWNjNmYwZDY5NzI2YzgyYzE3YjhkMTliMzY0OWMwZDNlYWIzNGMyOTE1YTIzZTc0MGExMzE2Yjg4MTU0YmI3MDQ5MmI1In0.eyJhdWQiOiIxOTUiLCJqdGkiOiIxZGIwYWZmMGNiMjVjYzZmMGQ2OTcyNmM4MmMxN2I4ZDE5YjM2NDljMGQzZWFiMzRjMjkxNWEyM2U3NDBhMTMxNmI4ODE1NGJiNzA0OTJiNSIsImlhdCI6MTUxMjE0NjMxNywibmJmIjoxNTEyMTQ2MzE3LCJleHAiOjE1NDM2ODIzMTcsInN1YiI6IiIsInNjb3BlcyI6W119.o5lhoirAxlKI0C164bLvb6UTtSqNRiCAhLm6RIyq9SDKOXspgo3Ktk3otgQrM6r4FPACO3IHX671UVe_Ao3Q71jHxuqnTDifdO_HoYUZBUjCHYJ0yLGKIXaWTYl1MCZ2VP7t7plY13S9Jv_Jjqpr4UK8l3Ad8a2dcqA58gO00Y_M2YqsAX0syQoMV7WC7Zm9rIYz9fs1SEul2fZoSQRPXtl5u2j-JyEW3d8zwtlFPROiK_8DHIxKsQx7u8dAB_TxUnKneUq9-uXtQTx7h26tY0q38qQtS_ca4r_Vlr2Qx9CfEhcbdSfGP_hxHiUm68Hwp034aPvUn6KjSB8GhFyKVIGf2VQMTzkwSikFmjDAF0iPUPqQCLlsYv0Df_YKcd2-bRi7s2d6TJoB_uMlVKXZxJ-vCI0xmLo6ARW5qwWDIYrj90m7Zx4mRp1njlDTh2R3EIcFEbyWVaXttu3JiPbqiOiJ5Kc6PH2hAEelaZDtcywVGLUHeTp5C_oNjCmh8wWVXKUtnAYrz9p51hXl4Yd1xkSaue975vIs80KOD4SbCs9GfdfFHwdu28ncRb8EZgDLB2nUU_et7RYuLEPSqu5i1rrWj9f6OtyEUCadDhjq-mFe1wg9c8lSXBdjV0P5i_oN8eXflFnDxWUUhHUjhKkrMEdHO6Ixn4WzRzB63i3GwhU"
            self.expiration = 31536000
            self.lastAuthed = Date()
        #endif
    }
    
    convenience init(displayName:String, clientID:String, clientSecret:String) {
        self.init(clientID: clientID, clientSecret: clientSecret)
        self.displayName = displayName
    }
    
    // MARK: User
    public func authenticate(completion:@escaping (_ accessToken:String) -> Void){
 
        if self.checkToken(){
            completion(self.accessToken)
            return
        }
        let body = "grant_type=client_credentials&client_id=" + clientID + "&client_secret=" + clientSecret
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: AniList.baseURL + authEndpoint, body: body.data(using: .utf8), headers: /*self.headers*/nil) { (data, error) in
            
            
            if let json = data as? [String:Any]
            {
                os_log("%@: Returned data: %@",self.description, json)
                if let accessToken = json["access_token"] as? String, let expirationDate = json["expires_in"] as? Int{
                    self.accessToken = accessToken
                    self.expiration = expirationDate
                    self.lastAuthed = Date()
                    completion(self.accessToken)
                }
                else if let error = json["error"] as? String, let message = json["message"] as? String{
                    os_log("%@: Error: %@ with message: %@", type: .error, error, message)
                }
            }
        }
    }
    
    public func user(completion:@escaping (_ userInfo:[String:Any]) -> Void)
    {
        guard self.checkToken() else {
            os_log("%@: No access token, can't proceed with call", log: .default, type: .error, self.description)
            return
        }
        
        let url = AniList.baseURL + "user/\(self.clientID!)\(self.auth)"
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: url, body: nil, headers: self.headers) { (data, error) in
            if let json = data as? [String:Any]
            {
                os_log("%@: Returned data: %@", self.description, json)
                completion(json)
            }
        }
    }
    
    public func anime(for season:String, completion:@escaping (_ anime:[String:Any]) -> Void){
        let url = AniList.baseURL
        let body = ["season":season]
        Requester.sharedInstance.makeHTTPRequest(method: "POST", url: url, body: body, headers: self.headers) { (data, error) in
            if let json = data as? [String:Any]{
                completion(json)
            }
        }
    }
    
    private func checkToken() -> Bool{
        return (self.accessToken != nil && self.expiration != nil && self.lastAuthed != nil &&
            (self.lastAuthed.addingTimeInterval(31536000) > Date()))
    }
    
}
