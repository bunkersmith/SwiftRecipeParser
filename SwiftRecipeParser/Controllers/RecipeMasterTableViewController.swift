//
//  RecipeMasterTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class RecipeMasterTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressLabel: UILabel!
    
    private var selectedRow:NSInteger = -1
    private var selectedSection:NSInteger = -1
    private var expandedCells:Array<NSIndexPath> = Array()

    private var searchBarText:String?

    private var initializationCompleted:Bool = false

    private var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    private var sectionIndexTitles:Array<String> = Array()
    private var sectionTitles:Array<String> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //selectedRow = -1
        //selectedSection = -1
        
        progressLabel.alpha = 0.0
        searchBar.alpha = 0.0
        searchBarText = nil

        registerForNotifications()
    }

    func viewDidUnloadd() {
        // Need to redo the code flow for registering for and deregistering from notifications
        deregisterFromNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initializationCompleted {
            let databaseRecipeCount:Int = RecipeUtilities.countOfRecipes()
            
            if databaseRecipeCount > 0 {
                NSLog("Database contains \(databaseRecipeCount) recies - no updates will be made from recipe resource files");
                loadRecipeTable()
            }
            else {
                progressLabel.alpha = 1.0
                progressLabel.text = "Creating Recipe Database..."
                var recipeFiles:RecipeFiles = RecipeFiles()
                recipeFiles.initializeRecipeDatabaseFromResourceFiles()
            }
        
            initializationCompleted = true
            let utilities:Utilities = Utilities.instance
            NSLog("App Startup Time = %.3f", Utilities.currentTickCount()-utilities.appStartupTime)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createNewFetchedResultsController(searchString:String?) {
        let databaseInterface:DatabaseInterface = DatabaseInterface()
        
        if searchString != nil {
            fetchedResultsController = databaseInterface.createFetchedResultsController("Recipe", sortKey: "indexCharacter", secondarySortKey: nil, fetchRequestChangeBlock:{
            inputFetchRequest in
                var predicate:NSPredicate = NSPredicate(format: "name contains[cd] %@", searchString!)
                inputFetchRequest.predicate = predicate
                return inputFetchRequest
            })
        }
        else {
            fetchedResultsController = databaseInterface.createFetchedResultsController("Recipe", sortKey: "indexCharacter", secondarySortKey: nil, fetchRequestChangeBlock:nil)
        }
        
        sectionTitles = Utilities.convertSectionTitles(fetchedResultsController)
        sectionIndexTitles = Utilities.convertSectionIndexTitles(fetchedResultsController)
        
        fetchedResultsController.delegate = self
        tableView.reloadData()
    }
    
    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            var point:CGPoint = recognizer.locationInView(tableView)
            var indexPath:NSIndexPath? = tableView.indexPathForRowAtPoint(point)
            if indexPath != nil {
                if indexPath!.section != 0 {
                    expandOrContractCellLabel(indexPath!)
                }
            }
        }
    }
    
    func storeCellIsExpandedValueForIndexPath(indexPath: NSIndexPath, newValue: Bool)
    {
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if indexPath.section != 0 {
            var itemIndex:Int? = find(expandedCells, indexPath)
            
            if newValue == false && itemIndex != nil {
                expandedCells.removeAtIndex(itemIndex!)
            }
            else {
                if newValue == true && itemIndex == nil {
                    expandedCells.append(indexPath)
                }
            }
        }
    }
    
    func expandOrContractCellLabel(indexPath:NSIndexPath)
    {
        //NSLog(@"%s called for indexPath = %i, %i", __PRETTY_FUNCTION__, indexPath.section, indexPath.row );
        
        var currentValue:Bool = fetchCellIsExpandedValueForIndexPath(indexPath)
        
        if currentValue {
            storeCellIsExpandedValueForIndexPath(indexPath, newValue:false);
        }
        else {
            storeCellIsExpandedValueForIndexPath(indexPath, newValue:true);
        }
        
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        tableView.endUpdates()
    }
    
    func fetchCellIsExpandedValueForIndexPath(indexPath:NSIndexPath) -> Bool
    {
        var returnValue:Bool = false
        //return returnValue;
        
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if indexPath.section != 0
        {
            if find(self.expandedCells, indexPath) != nil {
                returnValue = true
            }
        }
        
        return returnValue;
    }
    
    func configureLabelForCell(cell:UITableViewCell, expandedFlag:Bool, recipeTitle:NSString)
    {
        if expandedFlag {
            cell.layoutIfNeeded()
            
            //NSLog(@"recipeTitle = *%@* for indexPath = %i, %i", recipeTitle, indexPath.section, indexPath.row);
            
            cell.textLabel!.font = UIFont.boldSystemFontOfSize(17.0)
            cell.textLabel!.numberOfLines = 0
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel!.text = recipeTitle as String
        }
        else {
            cell.textLabel!.font = UIFont.boldSystemFontOfSize(17.0)
            cell.textLabel!.numberOfLines = 1
            cell.textLabel!.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            cell.textLabel!.text = recipeTitle as String
        }
    }
    
    func rowsInRecipeSection(section:NSInteger) -> NSInteger
    {
        var returnValue:NSInteger = 0
        
        if section != 0
        {
            // Return the number of rows in the section.
            var sections:NSArray = fetchedResultsController.sections!
            
            var sectionInfo:NSFetchedResultsSectionInfo;
            sectionInfo = fetchedResultsController.sections?[section - 1] as! NSFetchedResultsSectionInfo
            
            NSLog("Number of objects in section %d: %d", section, sectionInfo.numberOfObjects)
            
            returnValue = sectionInfo.numberOfObjects
        }
        
        return returnValue
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:NSIndexPath) {
        
        //NSLog(@"%s called with indexPath.section = %d, indexPath.row = %d", __PRETTY_FUNCTION__, indexPath.section, indexPath.row);
        
        // Index path includes section 0
        var cellIsExpanded:Bool = fetchCellIsExpandedValueForIndexPath(indexPath)
        
        //NSLog(@"recipeTitle = %@ (expandedFlag = %i)", recipeTitle, expandedFlag);
        
        var realIndexPath:NSIndexPath = NSIndexPath(forRow: indexPath.row , inSection: indexPath.section-1)
        
        var recipe:Recipe = fetchedResultsController.objectAtIndexPath(realIndexPath) as! Recipe
        
        // Configure the cell...
        configureLabelForCell(cell, expandedFlag:cellIsExpanded, recipeTitle:recipe.name)
        
        //Recipe *currentRecipe = [fetchedResultsController objectAtIndexPath:indexPath];
        
        //tableViewCell.textLabel.text = currentRecipe.name;
    }
    
    func registerForNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("handleRecipeProgressNotification:"), name: "RecipeProgressNotification", object: nil)
        notificationCenter.addObserver(self, selector: Selector("handleRecipeTableNeedsReloadNotification:"), name: "RecipeTableNeedsReloadNotification", object: nil)
    }
    
    func deregisterFromNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: "RecipeProgressNotification", object: nil)
        notificationCenter.removeObserver(self, name: "RecipeTableNeedsReloadNotification", object: nil)
    }
    
    func handleRecipeProgressNotification(notification:NSNotification)
    {
        var userInfo:NSDictionary = notification.userInfo as! Dictionary<NSString, NSNumber>
        var percentage:NSNumber = userInfo.objectForKey("percentage") as! NSNumber
        
        if (percentage != 0)
        {
            //NSLog("Progress percentage: %.0f", percentage.floatValue)
            dispatch_async(dispatch_get_main_queue(), {
                self.updateProgressLabel(percentage.floatValue)
            })
        }
    }
    
    func handleRecipeTableNeedsReloadNotification(notification:NSNotification)
    {
        tableView.reloadData();
    }
        
    func updateProgressLabel(percentage:Float)
    {
        progressLabel.text = String(format:"Creating Recipe Database: %.0f%%", percentage)
        
        if percentage == 100.0 {
            progressLabel.alpha = 0.0
            loadRecipeTable();
        }
    }
    
    func loadRecipeTable() {
        createNewFetchedResultsController(searchBarText)
    
        //tableView.reloadData()
    
        //RecipeUtilities.outputAllRecipesToFiles(true);
    }
    
    func showHideSearchBar()
    {
        if searchBar.alpha == 0.0 {
            searchBar.alpha = 1.0
            resizeTableView(55.0)
        }
        else {
            self.searchBar.alpha = 0.0
            resizeTableView(-55.0)
            tableView.reloadData()
        }
    }
    
    func resizeTableView(amount: CGFloat)
    {
        var tableFrame:CGRect = tableView.frame
        tableFrame.origin.y += amount
        tableFrame.size.height -= amount
        tableView.frame = tableFrame
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        var returnValue:Int = 0
        
        if (fetchedResultsController.sections != nil) {
            returnValue = fetchedResultsController.sections!.count + 1
        }

        //NSLog("Number of sections in table view \(returnValue)")
        
        return returnValue
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        var returnValue:Int = 0;
        
        if section != 0 {
            if (self.fetchedResultsController.sections != nil) {
                // Return the number of rows in the section.
                var sections:Array<NSFetchedResultsSectionInfo> = self.fetchedResultsController.sections as! Array<NSFetchedResultsSectionInfo>
                
                var sectionInfo:NSFetchedResultsSectionInfo
                sectionInfo = sections[section - 1]
                
                //NSLog("Number of objects in section %d: %d", section, sectionInfo.numberOfObjects);
                
                returnValue = sectionInfo.numberOfObjects;
            }
        }
        
        return returnValue;
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue:String = ""
        
        if section != 0 {
            returnValue = self.sectionTitles[section]
        }
        
        return returnValue
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if index == 0 {
            showHideSearchBar()
        }
        
        return index
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RecipeTableCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("RecipeDetailSegue", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "RecipeDetailSegue" {
            let detailViewController:RecipeDetailViewController = segue.destinationViewController as! RecipeDetailViewController
            
            var indexPath:NSIndexPath = tableView.indexPathForSelectedRow()!
            var realIndexPath:NSIndexPath = NSIndexPath(forRow: indexPath.row , inSection: indexPath.section-1)
            
            detailViewController.recipe = fetchedResultsController.objectAtIndexPath(realIndexPath) as? Recipe
        }
    }

    // MARK: - UISearchBar Delegate Methods
    
    func clearSearchBarText() {
        searchBar.text = ""
        searchBarText = nil
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        clearSearchBarText()
        searchBar.resignFirstResponder()
        showHideSearchBar()
        createNewFetchedResultsController(searchBarText)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.searchBarText = nil
        }
        else {
            searchBarText = searchText
        }
        
        createNewFetchedResultsController(searchBarText)
    }
    

}
