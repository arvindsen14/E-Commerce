//
//  NetworkManager.swift
//  News
//
//  Created by Arvind Sen on 08/05/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import Foundation

enum MethodName: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum ResponseStatus: String {
    case success = "Success"
    case failed  = "Failed"
}

/**
 Class Name: NetworkManager
 Purpose: This class is reponsible to handle all the server side api requests.
 **/

class NetworkManager: NSObject {
    var methodName = MethodName.get
    
    func callService ( urlString : String, httpMethod: MethodName, completion: @escaping (_ result: [String: Any]) -> Void)
    {
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        // Set the method to POST
        request.httpMethod = httpMethod.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if data == nil
            {
                var errorResponse = [String : Any]()
                errorResponse["Error"] = "Issue"
                errorResponse["Status"] = "Failed"
                completion(errorResponse)
            }
            else
            {
                if  let utf8Text = String(data: data! , encoding: .utf8) {
                    completion(self.getJSONData(text: utf8Text)!);
                }
                else
                {
                    var errorResponse = [String : Any]()
                    errorResponse["Error"] = "Issue"
                    errorResponse["Status"] = "Failed"
                    completion(errorResponse)
                }
            }
        })
        task.resume()
    }
 
    func getJSONData(text: String)->[String: Any]?{
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                let data = try JSONSerialization.jsonObject(with: data, options: [])
                var response = [String : Any]()
                response["Response"] = data
                response["Status"] = "Success"
                return response;
            } catch let error as NSError {
                var errorResponse = [String : Any]()
                errorResponse["Error"] = "JSON serialization Failed"
                errorResponse["Status"] = "Failed"
                print(error)
                return errorResponse
            }
        }
        return nil
    }
}
