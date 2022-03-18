//
//  GroceryItemPhotoViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 11/18/17.
//  Copyright © 2017 CarlSmith. All rights reserved.
//

import UIKit

class GroceryItemPhotoViewController: UIViewController {

    @IBOutlet weak var imageScrollView: ImageScrollView!
    
    var groceryListItem: GroceryListItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        guard let fullResImage = groceryListItem.readItemImage() else {
            return
        }

        imageScrollView.display(image: fullResImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
