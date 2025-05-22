//
//  ListVc.swift
//  TravelBookLastV
//
//  Created by Ali Ünal UZUNÇAYIR on 20.05.2025.
//

import UIKit
import CoreData

class ListVc: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
   var nameArrry = [String]()
    var IdArrry = [UUID]()
    var chsoenName = ""
    var chosenId : UUID?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addTapped))
        
        getdata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getdata), name: NSNotification.Name("reloadData"), object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tosec"{
            let destVC = segue.destination as! ViewController
            destVC.selectedNmae = chsoenName
            destVC.selectedId = chosenId
        }
      
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chsoenName = nameArrry[indexPath.row]
        chosenId = IdArrry[indexPath.row]
        performSegue(withIdentifier: "tosec", sender: nil)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  nameArrry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArrry[indexPath.row]
        return cell
    }
    
    @objc func addTapped(){
        chsoenName = ""
        performSegue(withIdentifier: "tosec", sender: nil)
    }
    @objc func getdata() {
        nameArrry.removeAll(keepingCapacity: false)
        IdArrry.removeAll(keepingCapacity: false)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
           let result =  try context.fetch(request)
            
            for res in result as! [NSManagedObject]{
                if let name = res.value(forKey: "title") as? String  {
                    nameArrry.append(name)
                }
                if let id = res.value(forKey: "id") as? UUID{
                    IdArrry.append(id)
                }
                tableView.reloadData()
            }
            
        }catch {
            print("error")
        }
    }
    
    

}
