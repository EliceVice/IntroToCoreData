
//
//  ViewController.swift
//  IntroToCoreData
//
//  Created by Andrei Isayenka on 25/10/2023.
//

import UIKit
import CoreData

class PeopleVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Data for the tableView
    var items: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Get items from Core Data
        fetchPeople()
    }
    
    private func fetchPeople() {
        
        // Fetch the data from CoreData to display in the tableView
        do {
            // Get request
            let request = Person.fetchRequest()
            
            // Set the filtering on the request using NSPredicate
//            let predicate = NSPredicate(format: "name CONTAINS 'Mike'")
//            let predicate = NSPredicate(format: "name CONTAINS %@", "Elice")
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
//            request.predicate = predicate
            
            // Set the sorting on the request using NSSortDescriptor
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sortDescriptor]
            
            // Pass the request to the fetch method
            items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print(error)
        }
    }
    
    // Just a test function
    private func relationshipDemo() {
        
        // Create family
        let family = Family(context: context)
        family.name = "Wattson family"
        
        // Create person
        let person = Person(context: context)
        person.name = "Alice"
        
        // Add family for person
        person.family = family
        
        // Add person for family
        family.addToPeople(person)
        
        // Save context
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    @IBAction func didTapAddButton(_ sender: Any) {
        
        // Create alert
        let alert = UIAlertController(title: "Add Person", message: "What is the name of the person?", preferredStyle: .alert)
        alert.addTextField()
        
        // Create cancel
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Configure button handler
        let submitButton = UIAlertAction(title: "Add", style: .default) { [weak self] action in
            
            guard let self else { return }
            
            // Get the textfield for the alert
            let textField = alert.textFields?.first
            
            // Create a new person in the context
            let newPerson = Person(context: self.context)
            newPerson.name = textField?.text
            newPerson.age = 20
            newPerson.gender = "Male"

            // Save the data
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Add buttons
        alert.addAction(cancelButton)
        alert.addAction(submitButton)
        
        // Show alert
        present(alert, animated: true)
    }

}


extension PeopleVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        let person = items[indexPath.row]
        cell.textLabel?.text = person.name
        
        return cell
    }
    
}


extension PeopleVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Selected person
        let person = items[indexPath.row]
        
        // Create alert
        let alert = UIAlertController(title: "Edit person", message: "Change the name of the person", preferredStyle: .alert)
        alert.addTextField()
        
        // Add persons name to the textfield
        let textField = alert.textFields![0]
        textField.text = person.name
        
        // Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            
            guard let self else { return }
            
            // Get the textField for the alert
            let textField = alert.textFields![0]
            
            // Edit whatever you want to change of person object
            person.name = textField.text
            
            // Save the data
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        // Add Button
        alert.addAction(saveButton)
        
        // Show the alert
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            
            guard let self else { return }
            
            // Which person to remove
            let personToRemove = self.items[indexPath.row]
            
            // Remove the person
            self.context.delete(personToRemove)
            
            // Save the data
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            
            // Re-fetch the data
            self.fetchPeople()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}
