//
//  RecipeTableSearchHeaderViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 6/12/16.
//  Copyright © 2016 CarlSmith. All rights reserved.
//

import UIKit

enum RecipeSearchType {
    case RecipeTitle
    case Ingredient
}

protocol RecipeSearchTypeDelegate: class {
    func RecipeSearchTypeChanged(searchType: RecipeSearchType)
}

class RecipeTableSearchHeaderViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchType: RecipeSearchType!

    weak var delegate: RecipeSearchTypeDelegate?
    
    //@IBOutlet weak var searchBarSuperview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Logger.logDetails(msg: "Entered")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Logger.logDetails(msg: "Entered")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchTypeChanged(_ sender: Any) {
        //Logger.logDetails(msg: "Entered")
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            searchType = .RecipeTitle
            delegate?.RecipeSearchTypeChanged(searchType: .RecipeTitle)
        case 1:
            searchType = .Ingredient
            delegate?.RecipeSearchTypeChanged(searchType: .Ingredient)
        default:
            break
        }
        
        //Logger.logDetails(msg: "searchType = \(searchType!)")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
