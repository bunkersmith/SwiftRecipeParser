//
//  RecipeMasterTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit

class RecipeMasterTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    private var selectedRow:NSInteger?
    private var selectedSection:NSInteger?
    private var expandedCells:Array<NSIndexPath>?

    private var searchBarText:String?
    
/*
    init() {
        super.init(nibName: nil, bundle: nil)
    }
*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedRow = -1
        self.selectedSection = -1
        
        self.searchBar.alpha = 0.0
        self.searchBarText = nil

        registerForNotifications()
    }

    func viewDidUnloadd() {
        // Need to redo the code flow for registering for and deregistering from notifications
        deregisterFromNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let countOfRecipes:Int = RecipeUtilities.countOfRecipes()
        NSLog("countOfRecipes = \(countOfRecipes)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            var point:CGPoint = recognizer.locationInView(self.tableView)
            var indexPath:NSIndexPath? = self.tableView.indexPathForRowAtPoint(point)
            if indexPath {
                NSLog("indexPath = \(indexPath)")
            }
            else {
                NSLog("indexPath is nil")
            }
        }
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        if let recipeCell = cell as? RecipeTableViewCell {
            //if let measurement = fetchResultsController?.objectAtIndexPath(indexPath) as? Measurement {
            //    measurementCell.useMeasurement(measurement)
            //}
        }
    }
    
    func registerForNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("handleLoadNextRecipeNotification:"), name: "LoadNextRecipeNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("handleLoadPreviousRecipeNotification:"), name: "LoadPreviousRecipeNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("handleRecipeProgressNotification:"), name: "RecipeProgressNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("handleRecipeTableNeedsReloadNotification:"), name: "RecipeTableNeedsReloadNotification", object: nil)
    }
    
    func deregisterFromNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: "LoadNextRecipeNotification", object: nil)
        notificationCenter.removeObserver(self, name: "LoadPreviousRecipeNotification", object: nil)
        notificationCenter.removeObserver(self, name: "RecipeProgressNotification", object: nil)
        notificationCenter.removeObserver(self, name: "RecipeTableNeedsReloadNotification", object: nil)
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // Return the number of sections.
        return 0
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 0
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeTableCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
