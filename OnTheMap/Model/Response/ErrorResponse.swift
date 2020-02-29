//
//  ErrorResponse.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 29/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct ErrorResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case statusMessage = "error"
    }
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
