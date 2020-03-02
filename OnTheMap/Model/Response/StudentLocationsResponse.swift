//
//  StudentLocationsResponse.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 23/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct StudentLocationsResponse: Codable {
    let results: [StudentInformation]?
}
