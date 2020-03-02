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
        static var firstName = ""
        static var lastName = ""
        static var accountId = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://onthemap-api.udacity.com/v1"
        
        case session
        case getUserDetails(String)
        case getStudentLocations
        case postStudentLocation
        case putStudentLocation(String)
        
        var stringValue: String {
            switch self {
                case .session: return "\(Endpoints.base)/session"
                case .getUserDetails(let userId): return "\(Endpoints.base)/users/\(userId)"
                case .getStudentLocations: return "\(Endpoints.base)/StudentLocation?order=-updatedAt"
                case .postStudentLocation: return "\(Endpoints.base)/StudentLocation"
                case .putStudentLocation(let objectId): return "\(Endpoints.base)/StudentLocation/\(objectId)"
            }
        }
        
        var skipFirst5Characters: Bool {
            switch self {
                case .session: return true
                case .getUserDetails: return true
                case .getStudentLocations: return false
                case .postStudentLocation: return false
                case .putStudentLocation: return false
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
    
    private class func makePUTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, skipFirst5Characters: Bool, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = try! JSONEncoder().encode(body)
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
        let body = CreateSessionRequest(userData: userData)
        let url = Endpoints.session.url
        let skipFirst5Characters = Endpoints.session.skipFirst5Characters
        makePOSTRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: LoginResponse.self, body: body) { (response, error) in
            if let response = response {
                Session.accountId = response.account.key
                Session.sessionId = response.session.id
                completion(true, nil)
                
            } else {
                completion(false, error)
            }
        }
    }
    
    class func logout(completion: @escaping () -> Void) {
        var request = URLRequest(url: Endpoints.session.url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Regardless of a success or response of this API call, we want to log the user out, so clear everything
            Session.accountId = ""
            Session.sessionId = ""
            Session.firstName = ""
            Session.lastName = ""
            DispatchQueue.main.async {
                completion()
            }
        }
        task.resume()
    }
    
    class func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        let url = Endpoints.getUserDetails(Session.accountId).url
        let skipFirst5Characters = Endpoints.getUserDetails(Session.accountId).skipFirst5Characters
        makeGETRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: UserDataResponse.self) { (response, error) in
            if let response = response {
                Session.firstName = response.firstName
                Session.lastName = response.lastName
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func getStudentLocations(completion: @escaping (Bool, Error?) -> Void) {
        let url = Endpoints.getStudentLocations.url
        let skipFirst5Characters = Endpoints.getStudentLocations.skipFirst5Characters
        makeGETRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: StudentLocationsResponse.self) { (response, error) in
            if let response = response {
                guard let studentLocations = response.results else {
                    completion(false, nil)
                    return
                }
                LocationModel.studentLocations = studentLocations
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func postStudentLocation(studentInformation: StudentInformation, completion: @escaping (String?, Error?) -> Void) {
        let body = SendStudentLocationRequest(uniqueKey: studentInformation.uniqueKey, firstName: studentInformation.firstName, lastName: studentInformation.lastName, mapString: studentInformation.mapString, mediaURL: studentInformation.mediaURL, latitude: studentInformation.latitude, longitude: studentInformation.longitude)
        let url = Endpoints.postStudentLocation.url
        let skipFirst5Characters = Endpoints.postStudentLocation.skipFirst5Characters
        makePOSTRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: PostStudentLocationResponse.self, body: body) { (response, error) in
            if let response = response {
                completion(response.objectId, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func updateStudentLocation(studentInformation: StudentInformation, completion: @escaping (Bool, Error?) -> Void) {
        let body = SendStudentLocationRequest(uniqueKey: studentInformation.uniqueKey, firstName: studentInformation.firstName, lastName: studentInformation.lastName, mapString: studentInformation.mapString, mediaURL: studentInformation.mediaURL, latitude: studentInformation.latitude, longitude: studentInformation.longitude)
        let url = Endpoints.putStudentLocation(studentInformation.objectId).url
        let skipFirst5Characters = Endpoints.putStudentLocation(studentInformation.objectId).skipFirst5Characters
        makePUTRequest(url: url, skipFirst5Characters: skipFirst5Characters, responseType: PutStudentLocationResponse.self, body: body) { (response, error) in
            if response != nil {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
}
