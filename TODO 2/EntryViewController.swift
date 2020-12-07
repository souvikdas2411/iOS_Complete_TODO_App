//
//  EntryViewController.swift
//  TODO 2
//
//  Created by Souvik Das on 04/12/20.
//
import UserNotifications
import RealmSwift
import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField : UITextField!
    @IBOutlet var datePicker : UIDatePicker!
    
    private let realm = try! Realm()
    public var completionHandler: (() -> Void)?
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Below line is used to pop up the keyboard by default
        textField.becomeFirstResponder()
        
        //Capturing return button press...down to text field shoul return
        textField.delegate = self
        
        //Date obj(Date()) defaults to today
        datePicker.setDate(Date(), animated: true)
        

        
        
        
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func didTapSave(){
        if let text = textField.text, !text.isEmpty{
            
            let date = datePicker.date
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            realm.beginWrite()
            
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.item = text
            
            
            completionHandler?()

            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "TO DO"
            content.body = newItem.item
            content.sound = UNNotificationSound.default
            
            let uuid = UUID().uuidString
            
            newItem.uuid = uuid
            
            realm.add(newItem)
            
            try! realm.commitWrite()

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

            let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)

            center.add(request) { (error) in
                //Handle errors
                print("fail")
            }

            
            
            
            
            
            navigationController?.popToRootViewController(animated: true)
        }
        else{
            tap()
        }
        
        
    }
    func tap() {
        let uialert = UIAlertController(title: "Error", message: "Please fill in a To Do title", preferredStyle: UIAlertController.Style.alert)
        uialert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
       self.present(uialert, animated: true, completion: nil)
    }

}

