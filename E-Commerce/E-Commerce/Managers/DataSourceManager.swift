//
//  DataManager.swift
//  News
//
//  Created by Arvind Sen on 02/06/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import Foundation

/**
 Class Name: DataSourceManager
 Purpose: This class is responsible to handle all the api request related with local or server side request.
 **/

final class DataSourceManager: NSObject {
    
    static let shared = DataSourceManager()
    var localDbFileName: String?
    
    // Dependency injected for database file.
    lazy var localDbManager : LocalDbManager? = {
        if self.localDbFileName == nil {
            assertionFailure("DB file not setup, please first setup localDbFileName parameter to file name");
        }
        return LocalDbManager(dbFileName: self.localDbFileName!);
    }()
    
    lazy var netWorkManager: NetworkManager = {
        return NetworkManager();
    }()
    
    func fetchDataFromServerApi(_ apiUrl: String, methodName: MethodName, completionHandler: @escaping (_ result: [String:Any]) -> Void) {
        self.netWorkManager.callService(urlString: apiUrl, httpMethod: MethodName.get) { dataDict in
            completionHandler(dataDict);
            print(dataDict);
        }
    }
    
    func checkEntityHavingData(entity: String){
        
    }
}
