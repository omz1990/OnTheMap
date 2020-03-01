//
//  PostStudentLocationRequest.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 2/3/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct SendStudentLocationRequest: Codable {
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
}
