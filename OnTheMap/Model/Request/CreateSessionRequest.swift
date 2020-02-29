//
//  CreateSessionRequest.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 29/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct CreateSessionRequest: Codable {
    let userData: CreateSessionUdacityRequest
    
    enum CodingKeys: String, CodingKey {
        case userData = "udacity"
    }
}
