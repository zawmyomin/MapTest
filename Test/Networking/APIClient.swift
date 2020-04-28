//
//  APIClient.swift
//  Test
//
//  Created by Justin Zaw on 24/04/2020.
//  Copyright © 2020 Justin Zaw. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient {
    
    static let shared = APIClient()
    
    func getDatalist(url: String,completion: @escaping (JSON, Int) -> Void){
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData{ (response) in
            let statusCode = response.response?.statusCode
            if statusCode == 200 {
                let json = JSON(response.result.value!)
                completion(json, statusCode!)
            }else{
                completion(JSON.null, statusCode!)
            }
        }
    }
    
    
    
}


