//
//  RecipeMasterTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class RecipeMasterTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressLabel: UILabel!
    
    var resultSearchController: UISearchController!
    var resultTableViewController: UITableViewController!
    var searchString: String!

    private var selectedRow:NSInteger = -1
    private var selectedSection:NSInteger = -1
    private var expandedCells:Array<NSIndexPath> = Array()

    private var initializationCompleted:Bool = false

    private var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
    private var sectionIndexTitles:Array<String> = Array()
    private var sectionTitles:Array<String> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //selectedRow = -1
        //selectedSection = -1
        
        progressLabel.alpha = 0.0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addScrollAreaView()
        createFetchedResultsController(nil)
        createSearchController()
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
                registerForNotifications()
                
                progressLabel.alpha = 1.0
                progressLabel.text = "Creating Recipe Database..."
                var recipeFiles:RecipeFiles = RecipeFiles()
                recipeFiles.initializeRecipeDatabaseFromResourceFiles()
            }
        
            initializationCompleted = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func addScrollAreaView() {
        var frame = tableView.bounds
        frame.origin.y = -frame.size.height;
        var blackView = UIView(frame: frame)
        blackView.backgroundColor = UIColor.blackColor()
        tableView.addSubview(blackView)
    }
    
    func createSearchController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        resultTableViewController = storyboard.instantiateViewControllerWithIdentifier("ResultsTableViewController") as! UITableViewController
        resultTableViewController.tableView.delegate = self
        resultTableViewController.tableView.dataSource = self
        
        resultSearchController = UISearchController(searchResultsController: resultTableViewController)
        resultSearchController.delegate = self
        resultSearchController.searchResultsUpdater = self
        resultSearchController.dimsBackgroundDuringPresentation = true
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.barStyle = .Default
        resultSearchController.searchBar.showsCancelButton = true
        resultSearchController.searchBar.delegate = self
        
        if let searchTextField = resultSearchController.searchBar.valueForKey("searchField") as? UITextField {
            searchTextField.textColor = UIColor.blackColor()
        }
        
        self.tableView.tableHeaderView = resultSearchController.searchBar
        hideSearchBar()
    }
    
    func showSearchBar() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
            self.tableView.contentOffset = CGPointZero
        })
    }
    
    func hideSearchBar() {
        if self.tableView.contentOffset == CGPointZero {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * Int64(NSEC_PER_MSEC)), dispatch_get_main_queue(), { () -> Void in
                self.tableView.contentOffset = CGPointMake(0.0, self.tableView.tableHeaderView!.frame.height)
            })
        }
    }
    
    func createFetchedResultsController(searchString:String?) {
        let databaseInterface:DatabaseInterface = DatabaseInterface()
        
        if searchString != nil {
            fetchedResultsController = databaseInterface.createFetchedResultsController("Recipe", sortKey: "title.indexCharacter", secondarySortKey: nil, sectionNameKeyPath:"title.indexCharacter", predicate:NSPredicate(format: "title.name contains[cd] %@", searchString!))
        }
        else {
            fetchedResultsController = databaseInterface.createFetchedResultsController("Recipe", sortKey: "title.indexCharacter", secondarySortKey: nil, sectionNameKeyPath: "title.indexCharacter", predicate:nil)
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
        configureLabelForCell(cell, expandedFlag:cellIsExpanded, recipeTitle:recipe.title.name)
        
        //Recipe *currentRecipe = [fetchedResultsController objectAtIndexPath:indexPath];
        
        //tableViewCell.textLabel.text = currentRecipe.name;
    }
    
    func registerForNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("handleRecipeProgressNotification:"), name: "RecipeProgressNotification", object: nil)
    }
    
    func deregisterFromNotifications() {
        let notificationCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: "RecipeProgressNotification", object: nil)
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
            deregisterFromNotifications()
            
            progressLabel.alpha = 0.0
            loadRecipeTable();
        }
    }
    
    func loadRecipeTable() {
        createFetchedResultsController(searchString)
    
        //tableView.reloadData()
    
        //RecipeUtilities.outputAllRecipesToFiles(true);
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        if index == 0 {
            showSearchBar()
        }
        
        return index
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 22.0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue:String = ""
        
        if section != 0 {
            returnValue = self.sectionTitles[section]
        }
        
        return returnValue
    }
    
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
            
            var selectedIndexPath:NSIndexPath? = resultTableViewController.tableView.indexPathForSelectedRow()
            if selectedIndexPath != nil {
                if let cell = resultTableViewController.tableView.cellForRowAtIndexPath(selectedIndexPath!) {
                    if cell.textLabel != nil && cell.textLabel!.text != nil {
                        if let recipe = RecipeUtilities.fetchRecipeWithName(cell.textLabel!.text!) {
                            detailViewController.recipe = recipe
                            resultSearchController.active = false
                        }
                    }
                }
            }
            else {
                var indexPath:NSIndexPath = tableView.indexPathForSelectedRow()!
                var realIndexPath:NSIndexPath = NSIndexPath(forRow: indexPath.row , inSection: indexPath.section-1)
                
                detailViewController.recipe = fetchedResultsController.objectAtIndexPath(realIndexPath) as? Recipe
            }
        }
    }

    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
    }
    
    // MARK: - Search Results Updater
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        var searchSring:String?
        
        if searchController.searchBar.text == "" {
            searchString = nil
        }
        else {
            searchString = searchController.searchBar.text
        }
        createFetchedResultsController(searchString)
        
        resultTableViewController.tableView.reloadData()
    }
    
}
