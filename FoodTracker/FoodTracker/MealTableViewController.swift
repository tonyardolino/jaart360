//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 11/15/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import os.log
import CloudKit

class MealTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        if let savedMeals = loadMeals() {
            meals += savedMeals
        }
        else {
            // Load the sample data.
            //loadSampleMeals()
            //print("viewDidLoad calling loadCloudMeals()")
            loadiCloudMeals()
            //saveMeals()
            /*
             print("before \(meals.count)")
             meals = [Meal]()
             print("after \(meals.count)")
             if let savedMeals = loadMeals() {
             meals += savedMeals
             print("loadMeals \(meals.count)")
             } else {
             print("viewDidLoad loadMeals failed")
             }
             */
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarning")
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(meals.count)")
        return meals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            //saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    //MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMeal = meals[indexPath.row]
            mealDetailViewController.meal = selectedMeal
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            //print("unwindToMealList sourceViewController.scrollView: \(sourceViewController.scrollView) sourceViewController.photoImageView: \(sourceViewController.photoImageView) sourceViewController.photoImageView?.subviews.first: \(sourceViewController.photoImageView?.subviews.first)")
            
            if (sourceViewController.photoImageView?.subviews.first != nil){
                UIGraphicsBeginImageContext((sourceViewController.photoImageView.image?.size)!)
                sourceViewController.photoImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
                meal.photo = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                saveScenes(meal: meal)
                
            } else { if let selectedIndexPath = tableView.indexPathForSelectedRow {
                        // Update an existing meal.
                        meals[selectedIndexPath.row] = meal
                        tableView.reloadRows(at: [selectedIndexPath], with: .none)
                    } else {
                        // Add a new meal.
                        let newIndexPath = IndexPath(row: meals.count, section: 0)
                
                        meals.append(meal)
                        tableView.insertRows(at: [newIndexPath], with: .automatic)
                        saveMeals(meal: meal)
                }
            }
            
            // Save the meals.
            }
    }
    
    //MARK: Private Methods
    
    private func loadSampleMeals() {
        
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4, size: "24x28") else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5, size: "24x28") else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3, size: "24x28") else {
            fatalError("Unable to instantiate meal2")
        }
        
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals(meal: Meal) {
        //print("saveMeals() called meal \(meal)")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meal, toFile: Meal.ArchiveURL.path)
        print("saveMeals completed \(isSuccessfulSave)")
        if isSuccessfulSave {
            print("Meals successfully saved.")
            //os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            print("Failed to save meals...")
            //os_log("Failed to save meals...", log: OSLog.default, type: .error)
            
        }
        
         let name = meal.name
         let rating = meal.rating
         let Image: UIImage = (meal.photo)!
         let size = meal.size
        
         
         
         let DocumentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
         let tempURL = DocumentDirectory.appendingPathComponent("temp")
         let data = UIImageJPEGRepresentation(Image, 1.0)!
         do {
         try data.write(to: tempURL)
         }
         catch {
         os_log("Failed to save temp...", log: OSLog.default, type: .error)
         }
         let asset = CKAsset(fileURL: tempURL)
         
         
         let artworkRecordID: CKRecordID = CKRecordID.init(recordName: name)
         let artworkRecord: CKRecord = CKRecord.init(recordType: "Artwork", recordID: artworkRecordID)
         artworkRecord["title"] = name as CKRecordValue
         artworkRecord["artist"] = "Jennifer Ardolino" as CKRecordValue
         artworkRecord["address"] =  "Homosassa, Florida" as CKRecordValue
         artworkRecord["rating"] = rating as CKRecordValue
         artworkRecord["image"] = asset
         artworkRecord["Size"] = size as CKRecordValue?
         
         let myContainer: CKContainer = CKContainer.default()
         let publicDatabase: CKDatabase = myContainer.publicCloudDatabase
         
         publicDatabase.save(artworkRecord) { savedRecord, error in
         }
        
        
    }
    
    private func saveScenes(meal: Meal) {
        //print("saveMeals() called meal \(meal)")
        //var username = UIDevice.current.name
        //var uuid = UIDevice.current.identifierForVendor
        UIImageWriteToSavedPhotosAlbum(meal.photo!, nil, nil, nil)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meal, toFile: Meal.scenesURL.path)
        print("saveScenes completed \(isSuccessfulSave)")
        if isSuccessfulSave {
            print("Scene successfully saved.")
            //os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            print("Failed to save meals...")
            //os_log("Failed to save meals...", log: OSLog.default, type: .error)
            
        }
        
        let name = meal.name
        let rating = meal.rating
        let Image: UIImage = (meal.photo)!
        let size = meal.size
        
        
        
        let DocumentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let tempURL = DocumentDirectory.appendingPathComponent("temp")
        let data = UIImageJPEGRepresentation(Image, 1.0)!
        do {
            try data.write(to: tempURL)
        }
        catch {
            os_log("Failed to save temp...", log: OSLog.default, type: .error)
        }
        let asset = CKAsset(fileURL: tempURL)
        
        
        let sceneRecordID: CKRecordID = CKRecordID.init(recordName: name)
        let sceneRecord: CKRecord = CKRecord.init(recordType: "Scenes", recordID: sceneRecordID)
        sceneRecord["title"] = name as CKRecordValue
        sceneRecord["artist"] = "Jennifer Ardolino" as CKRecordValue
        sceneRecord["address"] =  "Homosassa, Florida" as CKRecordValue
        sceneRecord["rating"] = rating as CKRecordValue
        sceneRecord["image"] = asset
        sceneRecord["Size"] = size as CKRecordValue?
        
        let myContainer: CKContainer = CKContainer.default()
        let publicDatabase: CKDatabase = myContainer.publicCloudDatabase
        
        publicDatabase.save(sceneRecord) { savedRecord, error in
            if((error) != nil) { print("saveScene database error: \(error)")}
        }
        
        
    }

    
    private func loadMeals() -> [Meal]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    private func loadiCloudMeals() {
        
        let myContainer: CKContainer = CKContainer.default()
        let publicDatabase: CKDatabase = myContainer.publicCloudDatabase
        let mypredicate = NSPredicate.init(value: true)
        //let size = "24x28"
        //let mypredicate = NSPredicate(format: "Size == %@", size)
        let myquery: CKQuery = CKQuery.init(recordType: "Artwork", predicate: mypredicate)
        //let myquery: CKQuery = CKQuery.init(recordType: "Art", predicate: mypredicate)
        
        
        publicDatabase.perform(myquery, inZoneWith:  nil, completionHandler: ({results, error in
            
            if(error != nil) {
                print("loadiCloudMeals iCLoud Query Failed... error: \(error)")
                os_log("iCLoud Query Failed...", log: OSLog.default, type: .error)
            } else {
                //var myMeal = [Meal]()
                //print("loadiCloudMeals iCLoud Query sucessful...")
                //os_log("iCLoud Query successfully.", log: OSLog.default, type: .debug)
                //print(results!.count)
                //var i: Int = 0
                for entry in results! {
                    //i += 1
                    //if (i > 10) {
                    //    break
                    //}
                    //print("recordID: \(entry.recordID)")
                    let name = entry["title"] as? String
                    let rating = entry["rating"] as? Int
                    
                    
                    guard let asset = entry["image"] as? CKAsset else {
                        print("Image missing from record")
                        return
                    }
                    guard let imageData = NSData(contentsOf: asset.fileURL) else {
                        print("Invalid Image")
                        return
                    }
                    let photo  = UIImage(data: imageData as Data)
                    //print("loadCloudMeals Name: \(name) Size: \(photo?.size)")
                    let size = entry["Size"] as? String
                    guard let icloudMeal = Meal(name: name!, photo: photo!, rating: rating!, size: size!)
                        else {
                            fatalError("Meals failed to init loadiCloudMeals")
                    }
                    self.meals += [icloudMeal]
                    
                    //print(" title \(name) \(rating) \(Size)")
                }
                /*
                 print("loadiCLoudMeal calling saveMeals()")
                 self.saveMeals()
                 print("before \(self.meals.count)")
                 self.meals = [Meal]()
                 print("after \(self.meals.count)")
                 if let savedMeals = self.loadMeals() {
                 self.meals += savedMeals
                 print("loadMeals \(self.meals.count)")
                 } else {
                 print("loadMeals failed")
                 }
                 */
                self.tableView.reloadData()
            }
        }))
        //return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    
}
