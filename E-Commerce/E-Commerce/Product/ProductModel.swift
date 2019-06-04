//
//  CategoryModel.swift
//  E-Commerce
//
//  Created by Arvind Sen on 02/06/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import Foundation
import CoreData

/**
 Structure Name: NewsFeedModel
 Purpose: This class is reponsible to store data.
 **/
struct ProductModel {
    
    var by: String?
    var descendants: String?
    var id: String?
    var score: Int?
    var time: String?
    var title: String?
    var type: String?
    var url: String?
    var readStatus: Int = 0
    
    init() {
    }
    
    mutating func mapData(_ dict: [String: Any?]) {
        self.by = dict["by"] as? String
        self.descendants = dict["descendants"] as? String
        self.id = dict["id"] as? String
        self.score = dict["score"] as? Int
        self.time = dict["time"] as? String
        self.title = dict["title"] as? String
        self.type = dict["type"] as? String
    }
    
    mutating func mapDataWithLocalDB(_ dict: NSManagedObject) {
        self.by = dict.value(forKey: "by") as? String
        self.descendants = dict.value(forKey: "descendants") as? String
        self.id = dict.value(forKey: "id") as? String
        self.score = dict.value(forKey:"score") as? Int
        self.time = dict.value(forKey: "time") as? String
        self.title = dict.value(forKey: "title") as? String
        self.type = dict.value(forKey: "type") as? String
        self.url = dict.value(forKey: "url") as? String
        self.readStatus = dict.value(forKey: "readStatus") as! Int
    }
}
