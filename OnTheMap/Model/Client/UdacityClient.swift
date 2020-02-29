//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 29/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import Foundation

class UdacityClient {
    
    struct Session {
        static var firstName = "Bruce"
        static var lastName = "Wayne"
        static var accountId = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case login
        case getUserDetails(String)
        case getStudentLocations
        
        var stringValue: String {
            switch self {
                case .login: return "\(Endpoints.base)/session"
                case .getUserDetails(let userId): return "\(Endpoints.base)/users/\(userId)"
                case .getStudentLocations: return "\(Endpoints.base)/StudentLocation?order=-updatedAt"
            }
        }
        
        var skipFirst5Characters: Bool {
            switch self {
                case .login: return true
                case .getUserDetails: return true
                case .getStudentLocations: return false
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    private class func makeGETRequest<ResponseType: Decodable>(url: URL, skipFirst5Characters: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            /* subset response data! */
            let newData = skipFirst5Characters ? data.subdata(in: 5..<data.count) : data
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        
        return task
    }
    
    private class func makePOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, skipFirst5Characters: Bool, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(body)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            /* subset response data! */
            let newData = skipFirst5Characters ? data.subdata(in: 5..<data.count) : data
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: newData) as Error
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func login(userName: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        let userData = CreateSessionUdacityRequest(username: userName, password: password)
        let request = CreateSessionRequest(userData: userData)
        let url = Endpoints.login.url
        let skipFirst5Characters = Endpoints.login.skipFirst5Characters
        makePOSTRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: LoginResponse.self, body: request) { (response, error) in
            if let response = response {
                Session.accountId = response.account.key
                Session.sessionId = response.session.id
                completion(true, nil)
                
            } else {
                completion(false, error)
            }
        }
    }
}
