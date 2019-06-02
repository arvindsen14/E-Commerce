//
//  LocalDbManager.swift
//  News
//
//  Created by Arvind Sen on 08/05/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import Foundation
import CoreData

/**
 Class Name: LocalDbManager
 Purpose: This class is reponsible to handle all the local database requests like add/update/delete.
 **/

class LocalDbManager: NSObject {
    var localDbFileName: String?
    
    // MARK: - Core Data stack
    override init() {
        super.init();
    }
    
    convenience init(dbFileName: String) {
        self.init();
        localDbFileName = dbFileName
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: localDbFileName!)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Method to create new entity in local db
    func createAnEntity(entityName: String)->NSManagedObject {
        let context = self.persistentContainer.viewContext;
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context);
        return NSManagedObject(entity: entity!, insertInto: context)
    }
    
    // Method get call with entity object and the value we want to save in local db.
    func addValuesOnEntityWithArray(entity: String, arrayOfIds: [NSNumber], key: String){
        
        let context = self.persistentContainer.viewContext
        let entityWithName = NSEntityDescription.entity(forEntityName: entity, in: context)
        
        for value in arrayOfIds {
            let newObjToInsert = NSManagedObject(entity: entityWithName!, insertInto: context)
            newObjToInsert.setValue("\(value)", forKey: key)
        }
        self.saveContext()
    }
    
    // Method get call with entity object and the value we want to save in local db.
    func addValuesOnEntity(entity: String, keyValueDictionary: Dictionary<String, Any>){
        
        let context = self.persistentContainer.viewContext
        let entityWithName = NSEntityDescription.entity(forEntityName: entity, in: context)
        let newObjToInsert = NSManagedObject(entity: entityWithName!, insertInto: context)
        
        for (key, value) in keyValueDictionary{
            newObjToInsert.setValue(value, forKey: key)
        }
        self.saveContext()
    }
    
    // To fetch data from local db this method get call.
    func fetchDataFromEntity(entityName: String, filterPredicate: NSPredicate?, completionHandler: ((Any?, ResponseStatus)->Void)) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        //request.returnsObjectsAsFaults = false
        
        if let predicate = filterPredicate {
            request.predicate = predicate;
        }
        
        do {
            let result = try self.persistentContainer.viewContext.fetch(request)
            //            for data1 in result as! [NSManagedObject] {
            //                //print(data.value(forKey: "firstname") as! String)
            //            }
            completionHandler(result, .success);
        } catch {
            print("Failed")
            completionHandler(nil, .failed);
        }
    }
    
    // Method get called to delete one or more data for a entry from database
    func deleteRecordFromEntity(entityName: String, filterPredicate: NSPredicate?, completionHandler: ((Bool, String)->Void)){
        let context = self.persistentContainer.viewContext;
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = filterPredicate
        do
        {
            let fetchedResults =  try context.fetch(request) as? [NSManagedObject]
            for entity in fetchedResults! {
                context.delete(entity)
            }
            self.saveContext()
            completionHandler(true, "Data deleted successfully");
        }
        catch _ {
            print("Could not delete")
            completionHandler(false, "Data could not deleted at the moment, please try again later");
        }
    }
    
    // Method get called to update an row for a entry
    func updateRecordForEntity(entityName: String, filterPredicate: NSPredicate?, keyValueDictionary: Dictionary<String, Any>,  completionHandler: ((Bool, String)->Void)){
        let context = self.persistentContainer.viewContext;
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let results = try context.fetch(request) as? [NSManagedObject]
            if results?.count != 0 { // Atleast one was returned
                for (key, value) in keyValueDictionary{
                    results![0].setValue(value, forKey: key)
                }
                completionHandler(true, "Data updated successfully");
            }
            completionHandler(true, "Data doesn't found to update");
            
        } catch {
            print("Fetch Failed: \(error)")
            completionHandler(false, "Data doesn't found to update");
        }
        
        self.saveContext();
    }
    
}
