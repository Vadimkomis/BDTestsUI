//
//  BDTests.swift
//  BDTest
//
//  Created by Derek Bronston on 2/16/17.
//  Copyright © 2017 Derek Bronston. All rights reserved.
//

import UIKit
import OHHTTPStubs


public class BDTests  {
    
    //DEFAULT ENVIORNMENT NAME, USED TO DETERMINE IF WE ARE IN TEST MODE. CHANGE FTO YOUR ENVIORMENT
     public var enviornmentName = "BD-UI-TEST"
    
    //DEFAULT HTTP RESPONSE CODE TO 200
     public var httpResponseCode:Int32 = 200
    
    public init(enviornmentName:String?){
        if let envName = enviornmentName {
            self.enviornmentName = envName
        }
    }
    
    /*
     CREATE TEST
     */
    public func createTest(jsonString:String?,jsonFile:String?,httpCode:Int32)->Bool{
        print("CREATE TEST")
        var created = false
        
        //SET THE HTTP RESPONSE CODE
        self.httpResponseCode = httpCode
        
        //DID WE PASS A STRING
        if jsonString != nil {
            let json = "{\"code\":\(httpResponseCode),\"data\":\(jsonString!)}"
            created = self.setClipboard(json: json)
            //assert(created)
        }
        
        //DID WE PASS A FILE URL
        if jsonFile != nil {
            
            //set clipboard data
            let json = "{\"code\":\(httpResponseCode),\"data-file\":\"\(jsonFile!)\"}"
            created = self.setClipboard(json: json)
            //assert(created)
        }
        //return success message
        return created
    }
    
    /*
     seed database
     */
    public func seedDatabase(json:String)->Bool{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName+"-model"), create: true)
        paste?.string = ""
        paste?.string = json
        
        if paste == nil { return false }
        return true
    }
    
    /**
     read database data
     */
    public func readDatabaseData()->String?{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName+"-model"), create: true)
        if paste == nil { return nil }
        
        //guard let json = paste?.string else { return nil }
        //guard let dict = self.convertToDictionary(text: json) else { return nil }
        
        //CLEAR CLIPBOARD
       //UIPasteboard.remove(withName: UIPasteboardName(rawValue: self.enviornmentName+"-model"))
        
        return paste?.string
    }
    
    
    
    public func removeTest(){
        self.removeStubs()
        UIPasteboard.remove(withName: UIPasteboardName(rawValue: self.enviornmentName))
        UIPasteboard.remove(withName: UIPasteboardName(rawValue: self.enviornmentName+"-model"))
    }
    
    public func removeModelTest(){
        self.removeStubs()
        UIPasteboard.remove(withName: UIPasteboardName(rawValue: self.enviornmentName+"-model"))
    }
    
    /*
     READ DATA FILE INTO STRING
     */
    public func openFileAndReadIntoString(urlString:String)->String?{
        if let dir = Bundle.main.path(forResource: urlString, ofType:"json"){
            do {
                let text2 = try String(contentsOfFile: dir)
                return text2
            }catch _ as NSError{
                return nil
            }
        }
        return nil
    }
    
    /*
     READ CLIPBOARD
     
     1. http code
     2. json string?
     3. json file
     
     */
    public func readClipboard()->String?{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName), create: true)
        
        if paste == nil { return nil }
        let clipString =  paste?.string
        
        //clean clipboard
        UIPasteboard.remove(withName: UIPasteboardName(rawValue: self.enviornmentName))
        
        return clipString
        
    }
    
    /*
     SET CLIPBOARD
     pass json into clipboard for later review
     
     
     1. http code
     2. json string?
     3. json file
     */
    public func setClipboard(json:String)->Bool{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName), create: true)
        paste?.string = ""
        paste?.string = json
        
        if paste == nil { return false }
        return true
    }
    
    /*
     CONVERT JSON TO DICTIONARY
     */
    public func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    /*
     DETERMINE RESOPNSE TEXT
     */
    public func determineResponseText(dict:[String:Any])->String?{
        
        if dict["data"] != nil {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict["data"]!, options: .prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                let response = String.init(data: jsonData, encoding: .utf8)
                guard let responseText = response else { assert(false); return nil}
                return responseText
            }catch _ as NSError{
                //assert(false);
                return nil
            }
        }
        
        if dict["data-file"] as? String != nil {
            
            guard let responseText = self.openFileAndReadIntoString(urlString: dict["data-file"]! as! String) else { assert(false); return nil }
            
            return responseText
        }
        //assert(false);
        return nil
    }
    
    /*
     STUB NETWORK
     */
    public func runTests()->Bool{
        
        guard let json = self.readClipboard() else { assert(false); return false }
        guard let dict = self.convertToDictionary(text: json) else { assert(false); return false }
        guard let responseText = self.determineResponseText(dict:dict) else { assert(false); return false }
        guard let httpCode = dict["code"] else { assert(false); return false }
        guard let code =  httpCode as? Int32 else { assert(false); return false }
        
        stub(condition: isMethodGET()) { request -> OHHTTPStubsResponse in
            let stubData = responseText.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data:stubData!, statusCode:code, headers:nil)
        }
        
        stub(condition: isMethodPOST()) { request -> OHHTTPStubsResponse in
            let stubData = responseText.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data:stubData!, statusCode:code, headers:nil)
        }
        
        stub(condition: isMethodPUT()) { request -> OHHTTPStubsResponse in
            let stubData = responseText.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data:stubData!, statusCode:code, headers:nil)
        }
        
        stub(condition: isMethodPATCH()) { request -> OHHTTPStubsResponse in
            let stubData = responseText.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data:stubData!, statusCode:code, headers:nil)
        }
        
        stub(condition: isMethodDELETE()) { request -> OHHTTPStubsResponse in
            let stubData = responseText.data(using: String.Encoding.utf8)
            return OHHTTPStubsResponse(data:stubData!, statusCode:code, headers:nil)
        }
        return true
    }
    
    /**
     REMOVE STUBS
     */
    public func removeStubs(){
        OHHTTPStubs.removeAllStubs()
    }
    
    /*
     IS TEST
     */
    public func isTest()->Bool{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName), create: false)
        if paste?.string != nil {
            
            return true
        }
        return false
    }
    
    
    /*
     HAS MODEL TEST
     */
    public func isModelTest()->Bool{
        
        let paste = UIPasteboard(name: UIPasteboardName(rawValue: self.enviornmentName+"-model"), create: false)
        if paste?.string != nil {
            
            return true
        }
        return false
    }
}
