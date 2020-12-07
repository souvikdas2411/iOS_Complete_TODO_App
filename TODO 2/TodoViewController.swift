//
//  TodoViewController.swift
//  TODO 2
//
//  Created by Souvik Das on 04/12/20.
//

import RealmSwift
import UIKit

class TodoViewController: UIViewController {
    
    @IBOutlet var data : UITextView!
    @IBOutlet var date : UILabel!
    
    public var item : ToDoListItem?
    public var deletionHandler : (() -> Void)?
    
    private let realm = try! Realm()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        data.text = item?.item
        date.text = Self.dateFormatter.string(from: item!.date)
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        
        
    }
    
    @IBAction func didTapDelete(){
        guard let item = self.item else {
            return
        }
        
        if let text = data.text, !text.isEmpty{
            
            
            
            let setd = item.date
            try! realm.write{
                item.item = text
                item.date = setd
            }
        }
            

//        realm.beginWrite()
//        realm.delete(item)
//        try! realm.commitWrite()

        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
   

}
