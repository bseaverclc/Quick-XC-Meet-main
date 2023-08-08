//
//  UploadViewController.swift
//  Quick XC Meet
//
//  Created by Brian Seaver on 8/6/22.
//

import UIKit
import MessageUI

struct Result{
    var place: Int
    var first: String
    var last : String
    var gender : String
    var grade : Int
    var schoolFull : String
    var markString : String
    var raceName : String
}

class UploadViewController: UIViewController, MFMailComposeViewControllerDelegate {

    var resultsAthletes : [Athlete]!
    var schools : [String]!
    var meet : Meet!
    var selectedRace : String!
    var allRacesResults =  [Result]()
    var coaches = [String]()
    
    @IBOutlet weak var textViewOutlet: UITextView!
    let emailController = MFMailComposeViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        for (key,_) in meet.schools{
            for school in AppData.schoolsNew{
                if key == school.full{
                    for coach in school.coaches{
                        coaches.append(coach)
                    }
                    break
                }
            }
        }
        
        textViewOutlet.text = "Place, FirstName, LastName, Gender, Grade, Team, Time, Division\n"
        for ath in AppData.allAthletes{
            for race in ath.races{
                if race.meetName == meet.name && race.markString.count != 0{
                    allRacesResults.append(Result(place: race.place ?? 1000, first: ath.first, last: ath.last, gender: ath.gender, grade: ath.grade, schoolFull: ath.schoolFull, markString: race.markString, raceName: race.name))
                }
            }
        }
        
        allRacesResults = allRacesResults.sorted { (lhs, rhs) in
            if lhs.raceName == rhs.raceName { // <1>
                return lhs.place < rhs.place
            }
            
            return lhs.raceName < rhs.raceName // <2>
        }
        
        
        
        
        
        for result in allRacesResults{
            
                
                    textViewOutlet.text += "\(result.place ?? 1000), \(result.first), \(result.last), \(result.gender), \(result.grade), \(result.schoolFull), \(result.markString), \(result.raceName)\n"
                
                
        }
        
    }
    
    
    @IBAction func uploadAction(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = textViewOutlet.text!
        
 
        
        if let url = URL(string: "https://www.athletic.net/crosscountry/") {
                   UIApplication.shared.open(url)
               }
        
    }
    


    @IBAction func emailAction(_ sender: UIButton) {
        var csvString = textViewOutlet.text!
        print(csvString)
        let data = csvString.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        
                emailController.mailComposeDelegate = self
        emailController.setSubject("XC Results \(meet.name)")
        emailController.setMessageBody("I have attached the XC results for \(meet.name) as a csv file.  You can open it with Google Sheets", isHTML: false)

                // Attaching the .CSV file to the email.
                emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: "XCResults.csv")
    
        emailController.setToRecipients(coaches)
        
           if MFMailComposeViewController.canSendMail() {
               print("can send email")
               self.present(emailController, animated: true, completion: nil)
           }
        else{
            let alert = UIAlertController(title: "Error", message: "You need to set up the Mail App on your phone to send emails.  Go to Settings_Mail_Accounts and add your email account that you used to login to this app", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(alert, animated: true)
        }
        
        
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print (error)
        switch result {
               case .sent:
                   print("Email sent")
            let alert = UIAlertController(title: "Sent!", message: "If email was not received by others, check your password by going to Settings_Mail_Accounts and check the password for this email account.  Then try sending the email again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                controller.dismiss(animated: true)
            }))
            controller.present(alert, animated: true)
               case .saved:
                   print("Draft saved")
            controller.dismiss(animated: true)
               case .cancelled:
                   print("Email cancelled")
            controller.dismiss(animated: true)
               case  .failed:
                   print("Email failed")
            let alert = UIAlertController(title: "Sent!", message: "If email was not received, check your password by going to Settings_Mail_Accounts and check the password for this email account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                controller.dismiss(animated: true)
            }))
            controller.present(alert, animated: true)
               }
        
    }
    
}
