//
//  ProductVC.swift
//  E-Commerce
//
//  Created by Arvind Sen on 03/06/19.
//  Copyright © 2019 Aaryahi. All rights reserved.
//

import UIKit

class ProductVC: UIViewController {

    let viewModel = ProductViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //
        self.viewModel.removeAllTheData()
        self.viewModel.getDataFromApi(baseUrl)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
