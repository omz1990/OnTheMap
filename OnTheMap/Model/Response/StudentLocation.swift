//
//  StudentLocationResponse.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 23/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct StudentLocation: Codable {
    var objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let createdAt: String
    let updatedAt: String
}
