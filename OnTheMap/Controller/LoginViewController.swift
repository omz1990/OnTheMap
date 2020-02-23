//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Omar Mujtaba on 23/2/20.
//  Copyright © 2020 AmmoLogic Training. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var signupTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        getStudentLocations()
        addSignupLink()
    }

    func getStudentLocations() {
        let request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?order=-updatedAt")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Could not fetch results")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(StudentLocationsResponse.self, from: data)
                print(responseObject)
                print("Locations length: \(responseObject.results?.count ?? 0)")
                DispatchQueue.main.async {
//                    self.performSegue(withIdentifier: "loginComplete", sender: nil)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    private func addSignupLink() {
    
        let attributedString = NSMutableAttributedString(string: "Don't have an account? Sign Up")
        let url = URL(string: "https://auth.udacity.com/sign-up?next=https://classroom.udacity.com/authenticated")!

        attributedString.setAttributes([.link: url], range: NSMakeRange(23, 7))

        self.signupTextView.attributedText = attributedString
        self.signupTextView.isUserInteractionEnabled = true
        self.signupTextView.isEditable = false
        self.signupTextView.font = .systemFont(ofSize: 18.0)
        self.signupTextView.textAlignment = .center

        // Set how links should appear: blue and underlined
        self.signupTextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
}

