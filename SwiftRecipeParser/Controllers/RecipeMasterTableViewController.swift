//
//  RecipeMasterTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

@available(iOS 8.0, *)
class RecipeMasterTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressLabel: UILabel!
    
    var resultSearchController: UISearchController!
    var resultTableViewController: UITableViewController!
    var searchString: String!

    private var selectedRow:NSInteger = -1
    private var selectedSection:NSInteger = -1
    private var expandedCells:Array<IndexPath> = Array()

    private var initializationCompleted:Bool = false

    private var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = NSFetchedResultsController()
    private var sectionIndexTitles:Array<String> = Array()
    private var sectionTitles:Array<String> = Array()
    private var searchTextField:UITextField?

    private var searchHeaderViewController: RecipeTableSearchHeaderViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //selectedRow = -1
        //selectedSection = -1
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        progressLabel.alpha = 0.0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addScrollAreaView()
        createFetchedResultsController(searchString: nil)

        if searchHeaderViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            resultTableViewController = storyboard.instantiateViewController(withIdentifier: "ResultsTableViewController") as! UITableViewController
            resultTableViewController.tableView.delegate = self
            resultTableViewController.tableView.dataSource = self
            
            searchHeaderViewController = RecipeTableSearchHeaderViewController(nibName: "RecipeTableSearchHeaderView", bundle: nil)
            searchHeaderViewController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 600.0, height: 108.0)
            searchHeaderViewController!.searchBar.delegate = self
        }
 
        tableView.tableHeaderView = UIView(frame: searchHeaderViewController!.view.frame /*CGRectMake(0.0, 0.0, 600.0, 108.0)*/)
        tableView.tableHeaderView?.addSubview(searchHeaderViewController!.view)
        
        hideSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !initializationCompleted {
            let recipeFiles = RecipeFiles()
            let resourceRecipeCount = recipeFiles.countOfRecipeResourceFiles()
            
            let databaseRecipeCount:Int = RecipeUtilities.countOfDatabaseRecipes()
            
            if resourceRecipeCount != databaseRecipeCount || Utilities.forceLoadDatabase() {
                buildRecipeDatabase()
            }
            else {
                Logger.logDetails(msg: "Database contains \(databaseRecipeCount) recipes - no updates will be made from recipe resource files");
                self.loadRecipeTable()
            }
            initializationCompleted = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func buildRecipeDatabase() {
        registerForNotifications()
        
        tableView.alpha = 0.0
        progressLabel.alpha = 1.0
        progressLabel.text = "Creating Recipe Database..."
        let recipeFiles:RecipeFiles = RecipeFiles()
        recipeFiles.initializeRecipeDatabaseFromResourceFiles()
    }
    
    func addScrollAreaView() {
        var frame = tableView.bounds
        frame.origin.y = -frame.size.height;
        let whiteView = UIView(frame: frame)
        whiteView.backgroundColor = UIColor.white
        tableView.addSubview(whiteView)
    }
    
    func showSearchBar() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
            self.tableView.contentOffset = CGPoint(x: 0.0, y: 0.0)
            if self.searchTextField != nil {
                self.searchTextField!.becomeFirstResponder()
            }
        }
    }
    
    func hideSearchBar() {
        if self.tableView.contentOffset == CGPoint(x: 0.0, y: 0.0) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                self.tableView.contentOffset = CGPoint(x: 0.0, y: self.tableView.tableHeaderView!.frame.height)
            }
        }
    }
    
    func createFetchedResultsController(searchString:String?) {
        let databaseInterface:DatabaseInterface = DatabaseInterface()
        
        if searchString != nil {
            fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "Recipe", sortKey: "title.indexCharacter", secondarySortKey: "title.name", sectionNameKeyPath:"title.indexCharacter", predicate:NSPredicate(format: "title.name contains[cd] %@", searchString!))
        }
        else {
            fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "Recipe", sortKey: "title.indexCharacter", secondarySortKey: "title.name", sectionNameKeyPath: "title.indexCharacter", predicate:nil)
        }
        
        sectionTitles = Utilities.convertSectionTitles(fetchedResultsController: fetchedResultsController)
        sectionIndexTitles = Utilities.convertSectionIndexTitles(fetchedResultsController: fetchedResultsController)
        
        fetchedResultsController.delegate = self
        tableView.reloadData()
    }
    
    @IBAction func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            let point:CGPoint = recognizer.location(in: tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            if indexPath != nil {
                if indexPath!.section != 0 {
                    expandOrContractCellLabel(indexPath: indexPath!)
                }
            }
        }
    }
    
    func storeCellIsExpandedValueForIndexPath(indexPath: IndexPath, newValue: Bool)
    {
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if indexPath.section != 0 {
            let itemIndex:Int? = expandedCells.index(of: indexPath)
            
            if newValue == false && itemIndex != nil {
                expandedCells.remove(at: itemIndex!)
            }
            else {
                if newValue == true && itemIndex == nil {
                    expandedCells.append(indexPath)
                }
            }
        }
    }
    
    func expandOrContractCellLabel(indexPath:IndexPath)
    {
        //NSLog(@"%s called for indexPath = %i, %i", __PRETTY_FUNCTION__, indexPath.section, indexPath.row );
        
        let currentValue:Bool = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        if currentValue {
            storeCellIsExpandedValueForIndexPath(indexPath: indexPath, newValue:false);
        }
        else {
            storeCellIsExpandedValueForIndexPath(indexPath: indexPath, newValue:true);
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        tableView.endUpdates()
    }
    
    func fetchCellIsExpandedValueForIndexPath(indexPath:IndexPath) -> Bool
    {
        var returnValue:Bool = false
        //return returnValue;
        
        //NSLog(@"%s called for indexPath.section = %ld and indexPath.row = %ld", __PRETTY_FUNCTION__, (long)indexPath.section, (long)indexPath.row);
        
        if indexPath.section != 0
        {
            if self.expandedCells.index(of: indexPath) != nil {
                returnValue = true
            }
        }
        
        return returnValue;
    }
    
    func configureLabelForCell(cell:UITableViewCell, expandedFlag:Bool, recipeTitle:NSString)
    {
        cell.layoutIfNeeded()
        
        if let recipeMasterCell = cell as? MasterRecipeTableViewCell {
            if expandedFlag {
                //NSLog(@"recipeTitle = *%@* for indexPath = %i, %i", recipeTitle, indexPath.section, indexPath.row);
                
                recipeMasterCell.recipeNameLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
                recipeMasterCell.recipeNameLabel!.numberOfLines = 0
                recipeMasterCell.recipeNameLabel!.lineBreakMode = NSLineBreakMode.byWordWrapping
                recipeMasterCell.recipeNameLabel!.text = recipeTitle as String
            }
            else {
                recipeMasterCell.recipeNameLabel!.font = UIFont.boldSystemFont(ofSize: 17.0)
                recipeMasterCell.recipeNameLabel!.numberOfLines = 1
                recipeMasterCell.recipeNameLabel!.lineBreakMode = NSLineBreakMode.byTruncatingTail
                recipeMasterCell.recipeNameLabel!.text = recipeTitle as String
            }
        } else {
            cell.textLabel?.text = recipeTitle as String
        }
    }
    
    func rowsInRecipeSection(section:NSInteger) -> NSInteger
    {
        var returnValue:NSInteger = 0
        
        if section != 0
        {
            // Return the number of rows in the section.
            if let sectionInfo = fetchedResultsController.sections?[section - 1] {
                NSLog("Number of objects in section %d: %d", section, sectionInfo.numberOfObjects)
                returnValue = sectionInfo.numberOfObjects
            }
        }
        
        return returnValue
    }
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath:IndexPath) {
        
        //NSLog(@"%s called with indexPath.section = %d, indexPath.row = %d", __PRETTY_FUNCTION__, indexPath.section, indexPath.row);
        
        // Index path includes section 0
        let cellIsExpanded:Bool = fetchCellIsExpandedValueForIndexPath(indexPath: indexPath)
        
        //NSLog(@"recipeTitle = %@ (expandedFlag = %i)", recipeTitle, expandedFlag);
        
        let realIndexPath = IndexPath(row: indexPath.row , section: indexPath.section-1)
        
        let recipe:Recipe = fetchedResultsController.object(at: realIndexPath) as! Recipe
        
        // Configure the cell...
        configureLabelForCell(cell: cell, expandedFlag:cellIsExpanded, recipeTitle:recipe.title.name as NSString)
        
        //Recipe *currentRecipe = [fetchedResultsController objectAtIndexPath:indexPath];
        
        //tableViewCell.recipeNameLabel.text = currentRecipe.name;
    }
    
    func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(RecipeMasterTableViewController.handleRecipeProgressNotification(notification:)), name: NSNotification.Name(rawValue: "RecipeProgressNotification"), object: nil)
    }
    
    func deregisterFromNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "RecipeProgressNotification"), object: nil)
    }
    
    func handleRecipeProgressNotification(notification:NSNotification)
    {
        let userInfo = notification.userInfo as! Dictionary<NSString, NSNumber>
        
        let percentage = userInfo["percentage"]
        
        if (percentage != nil) {
            //NSLog("Progress percentage: %.0f", percentage.floatValue)
            DispatchQueue.main.async {
                self.updateProgressLabel(percentage: percentage!.floatValue)
            }
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
            tableView.alpha = 1.0
            loadRecipeTable();
        }
    }
    
    func loadRecipeTable() {
        createFetchedResultsController(searchString: searchString)
    
        //tableView.reloadData()
    
        //RecipeUtilities.outputAllRecipesToFiles(true);
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index == 0 {
            showSearchBar()
        }
        
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 22.0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var returnValue:String = ""
        
        if section != 0 {
            returnValue = self.sectionTitles[section]
        }
        
        return returnValue
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        var returnValue:Int = 0
        
        if (fetchedResultsController.sections != nil) {
            returnValue = fetchedResultsController.sections!.count + 1
        }

        //NSLog("Number of sections in table view \(returnValue)")
        
        return returnValue
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        var returnValue:Int = 0;
        
        if section != 0 {
            if (self.fetchedResultsController.sections != nil) {
                // Return the number of rows in the section.
                if let sections = self.fetchedResultsController.sections {
                    let sectionInfo = sections[section - 1]
                    
                    //NSLog("Number of objects in section %d: %d", section, sectionInfo.numberOfObjects);
                    
                    returnValue = sectionInfo.numberOfObjects;
                }
            }
        }
        
        return returnValue;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableCell", for: indexPath)

        // Configure the cell...
        configureCell(cell: cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "RecipeDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "RecipeDetailSegue" {
            let detailViewController:RecipeDetailViewController = segue.destination as! RecipeDetailViewController
            
            let selectedIndexPath:IndexPath? = resultTableViewController.tableView.indexPathForSelectedRow
            if selectedIndexPath != nil {
                if let cell = resultTableViewController.tableView.cellForRow(at: selectedIndexPath!) {
                    if cell.textLabel != nil && cell.textLabel!.text != nil {
                        if let recipe = RecipeUtilities.fetchRecipeWithName(recipeName: cell.textLabel!.text!) {
                            detailViewController.recipe = recipe
                            resultSearchController.isActive = false
                        }
                    }
                }
            }
            else {
                let indexPath:IndexPath = tableView.indexPathForSelectedRow!
                let realIndexPath:IndexPath = IndexPath(row: indexPath.row, section: indexPath.section-1)
                
                detailViewController.recipe = fetchedResultsController.object(at: realIndexPath) as? Recipe
            }
        }
    }

    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateTableWithSearchString(searchString: "")
        
        hideSearchBar()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTableWithSearchString(searchString: searchText)
    }

    func updateTableWithSearchString(searchString: String) {
        if searchString == "" {
            createFetchedResultsController(searchString: nil)
        }
        else {
            createFetchedResultsController(searchString: searchString)
        }
        
        resultTableViewController.tableView.reloadData()
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y <= 0 && searchTextField != nil {
            searchTextField!.becomeFirstResponder()
        }
    }
}
