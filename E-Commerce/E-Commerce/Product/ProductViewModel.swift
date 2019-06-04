//
//  ProductViewModel.swift
//  E-Commerce
//
//  Created by Arvind Sen on 03/06/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import UIKit
import CoreData

class ProductViewModel: NSObject {

    fileprivate var dataSourceManager: DataSourceManager!
    var completionHandler: ((Any, String?)->Void)?
    
    weak var controller: ProductVC?
    
    func setUpViewAndItsData(_ vc: ProductVC){
        controller = vc; DataSourceManager.shared.localDbManager?.deleteRecordFromEntity(entityName: "Product", filterPredicate: nil, completionHandler: { (status, msg) in
            self.fetchDataFromIds()
        })
    }
    
    func removeAllTheData(){
        let entityArray = ["Product", "Rank", "Category", "Tax", "Varient"]
        
        for entity in entityArray {
        DataSourceManager.shared.localDbManager?.deleteRecordFromEntity(entityName: entity, filterPredicate: nil, completionHandler: { (status, msg) in
                print(entity)
            })
        }
    }
    func fetchDataFromIds(){
       /* DataSourceManager.shared.localDbManager?.fetchDataFromEntity(entityName: "NewsIds", filterPredicate: nil, completionHandler: { (result, status) in
            if status == ResponseStatus.success {
                if (result as! [NSManagedObject]).count > 0{
                    
                    self.getAllStoriesData(result as! [NSManagedObject]);
                }
                else{
                    self.getDataOfNews(baseUrl + ApiConstant.topStories.rawValue);
                }
            }
            else{
                self.getDataOfNews(baseUrl + ApiConstant.topStories.rawValue);
            }
        })
        */
    }
    
    func getDataFromApi(_ apiUrl: String) {
        DataSourceManager.shared.fetchDataFromServerApi(apiUrl, methodName: MethodName.get) { (dict) in
            print(dict);
            if let dataDict = dict["Response"] as? NSDictionary {
                self.updateLocalDB(dataDict);
            }
        }
    }
    
    func updateLocalDB(_ dataDict: NSDictionary){
        if let categories = dataDict.value(forKey: "categories") as? NSArray {
            for dict in categories {
                
                // Save category data
                var newDict = [String : Any]()
                let categoryId = (dict as AnyObject).value(forKey: "id") as! Int16;
                newDict["id"] = categoryId;
                newDict["name"] = (dict as AnyObject).value(forKey: "name") as! String;
                if let parents = (dict as AnyObject).value(forKey: "child_categories") as? NSArray {
                    let parent = parents.componentsJoined(by: ",")
                    newDict["parentId"] = parent
                }
                
                DataSourceManager.shared.localDbManager?.addValuesOnEntity(entity: "Category", keyValueDictionary: newDict);
                
                // Save product data
                if let products = (dict as AnyObject).value(forKey: "products") as? NSArray, products.count > 0 {
                    
                    for product in products
                    {
                        var productDict = [String : Any]()
                        let productId = (product as AnyObject).value(forKey: "id") as! Int16;
                        productDict["id"] = (product as AnyObject).value(forKey: "id") as! Int16;
                        productDict["name"] = (product as AnyObject).value(forKey: "name") as! String;
                        productDict["categoryId"] = categoryId
                        
                        if let tax = (product as AnyObject).value(forKey: "tax") as? NSDictionary {
                            productDict["taxValue"] = (tax as AnyObject).value(forKey: "value") as! Float;
                            productDict["taxName"] = (tax as AnyObject).value(forKey: "name") as! String;
                        }
                        
                        DataSourceManager.shared.localDbManager?.addValuesOnEntity(entity: "Product", keyValueDictionary: productDict);
                    
                        // Save product variant
                        if let variants = (product as AnyObject).value(forKey: "variant") as? NSArray, variants.count > 0 {
                            for variant in variants {
                                var variantDict = [String : Any]()
                                variantDict["id"] = (variant as AnyObject).value(forKey: "id") as! Int16;
                                variantDict["size"] = (variant as AnyObject).value(forKey: "size") as? Float ?? 0.0;
                                variantDict["color"] = (variant as AnyObject).value(forKey: "color") as? String ?? "";
                                variantDict["price"] = (variant as AnyObject).value(forKey: "price") as? Float ?? 0.0;
                                variantDict["productId"] = productId
                                
                                DataSourceManager.shared.localDbManager?.addValuesOnEntity(entity: "Variant", keyValueDictionary: variantDict);
                            }
                        }
                    }
                }
            }
        }
        
        // Work on ranking
        if let rankings = dataDict.value(forKey: "rankings") as? NSArray {
            for ranking in rankings
            {
                if let rank = (ranking as AnyObject).value(forKey: "ranking") as? String, rank.lowercased() == "Most OrdeRed Products".lowercased() {
                   let products = (ranking as AnyObject).value(forKey: "products") as! NSArray
                    
                    for product in products {
                        let counter = (product as AnyObject).value(forKey: "order_count") as! Int
                        let id = (product as AnyObject).value(forKey: "id") as! Int
                        self.updateProductsForRank(rankType: "Ordered", productId: id, counter: counter);
                    }
                }
                
                if let rank = (ranking as AnyObject).value(forKey: "ranking") as? String, rank.lowercased() == "Most ShaRed Products".lowercased() {
                    let products = (ranking as AnyObject).value(forKey: "products") as! NSArray
                    
                    for product in products {
                        let counter = (product as AnyObject).value(forKey: "shares") as! Int
                        let id = (product as AnyObject).value(forKey: "id") as! Int
                        self.updateProductsForRank(rankType: "Shares", productId: id, counter: counter);
                    }
                }
                
                if let rank = (ranking as AnyObject).value(forKey: "ranking") as? String, rank.lowercased() == "Most Viewed Products".lowercased() {
                    let products = (ranking as AnyObject).value(forKey: "products") as! NSArray
                    
                    for product in products {
                        let counter = (product as AnyObject).value(forKey: "view_count") as! Int
                        let id = (product as AnyObject).value(forKey: "id") as! Int
                        self.updateProductsForRank(rankType: "Viewed", productId: id, counter: counter);
                    }
                }
            }
        }
    }
    
    func updateProductsForRank(rankType: String, productId: Int, counter: Int){
        let predicates = NSPredicate(format: "id == %@", productId)
        var dict = [String: Any]()
        dict["rankType"] = rankType
        dict["rankValue"] = counter
        DataSourceManager.shared.localDbManager?.updateRecordForEntity(entityName: "Product", filterPredicate: predicates, keyValueDictionary: dict, completionHandler: { (status, msg) in
            print("Data Inserted Successfully")
        })
    }
}
