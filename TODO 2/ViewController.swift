//
//  ViewController.swift
//  TODO 2
//
//  Created by Souvik Das on 04/12/20.
//
import UserNotifications
import RealmSwift
import UIKit

class ToDoListItem: Object{
    @objc dynamic var item: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var uuid: String = ""
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet var table : UITableView!
    
    private var data = [ToDoListItem]()
    private let realm = try! Realm()
    let sdata = ToDoListItem.self
    let generator = UINotificationFeedbackGenerator()

    
    
    static let dateFormatter1: DateFormatter = {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .full
        return dateFormatter1
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLongPressGesture()
//        self.title = "TODO(s)"
        //Putting values in data from realm
        data = realm.objects(ToDoListItem.self).map({$0})
        data.sort {($0.date < $1.date)}
        table.delegate = self
        table.dataSource = self
        
        
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //FUNCTION USED TO SET TABLE DATA
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let i = data[indexPath.row].item
        let d = Self.dateFormatter1.string(from: data[indexPath.row].date)
        cell.textLabel?.text = i
        cell.detailTextLabel?.text = d
        
        return cell
    }
    
    //FUNCTION USED TO SHOW A SPECIFIC ROW DATA
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = data[indexPath.row]
        guard let vc = storyboard?.instantiateViewController(identifier: "todo") as? TodoViewController else {
            return
        }
        vc.deletionHandler = {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
        vc.item = item
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete{
            let item = data[indexPath.row]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.uuid])
            realm.beginWrite()
            realm.delete(item)
            try! realm.commitWrite()
            generator.notificationOccurred(.success)
            self.refresh()
        }
    }
    
//    @IBAction func handleGesture(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began
//        {
//            let alertController = UIAlertController(title: nil, message:
//                "Long-Press Gesture Detected", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default,handler: nil))
//
//            present(alertController, animated: true, completion: nil)
//        }
//    }
    
    @IBAction func didTapAddButton(){
        
        guard let vc = storyboard?.instantiateViewController(identifier: "entry") as? EntryViewController else {
            return
        }
        
//        vc.navigationItem.largeTitleDisplayMode = .never
        
//        vc.completionHandler = { [weak self] in
//                self?.refresh()
//        }
        
        vc.completionHandler = {
            DispatchQueue.main.async {
                self.refresh()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func refresh(){
        data = realm.objects(ToDoListItem.self).map({$0})
        
        //data = realm.objects(ToDoListItem.self)
        data.sort {($0.date < $1.date)}
        table.reloadData()
    }
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: self.table)
            if let indexPath = table.indexPathForRow(at: touchPoint) {
                let temp = data[indexPath.row]
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [temp.uuid])
                realm.beginWrite()
                realm.delete(data[indexPath.row])
                try! realm.commitWrite()
                
                generator.notificationOccurred(.success)
                self.refresh()
            }
        }
    }
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        self.table.addGestureRecognizer(longPressGesture)
    }
    
}

