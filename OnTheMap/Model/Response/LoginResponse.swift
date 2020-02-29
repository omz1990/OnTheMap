//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 29/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let account: AccountResponse
    let session: SessionResponse
}
