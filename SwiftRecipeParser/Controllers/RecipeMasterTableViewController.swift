//
//  RecipeMasterTableViewController.swift
//  SwiftRecipeParser
//
//  Created by CarlSmith on 7/25/14.
//  Copyright (c) 2014 CarlSmith. All rights reserved.
//

import UIKit
import CoreData

class RecipeMasterTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, RecipeSearchTypeDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var progressLabel: UILabel!
    
    var resultTableViewController: UITableViewController!
    var searchString: String? = nil

    private var selectedRow:NSInteger = -1
    private var selectedSection:NSInteger = -1
    private var expandedCells:Array<IndexPath> = Array()

    private var initializationCompleted:Bool = false

    private var fetchedResultsController:NSFetchedResultsController<NSFetchRequestResult> = NSFetchedResultsController()
    private var sectionIndexTitles:Array<String> = Array()
    private var sectionTitles:Array<String> = Array()
    private var searchTextField:UITextField?

    private var searchHeaderViewController: RecipeTableSearchHeaderViewController?
    
// If you see a "UITableViewAlertForLayoutOutsideViewHierarchy error: Warning once only" message, before going crazy and trying to debug it...
//
// CLEAN THE PROJECT AND RESTART XCODE!!!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension

        progressLabel.alpha = 0.0
        
        // Called before warning appears (first call)
        tableView.tableFooterView = UIView(frame: .zero)
        
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
//        var unitsOfMeasure = Array<String>()
        
        if let groceryListItems = GroceryListItem.fetchAll() {
            
            var emptyItemCount = 0
            
            for groceryListItem in groceryListItems {
                if groceryListItem.name.isEmpty {
                    emptyItemCount += 1
                    databaseInterface.deleteObject(coreDataObject: groceryListItem)
                }
//                if !unitsOfMeasure.contains(groceryListItem.unitOfMeasure) {
//                    unitsOfMeasure.append(groceryListItem.unitOfMeasure)
//                }
            }
            
//            if let itemString = GroceryListItem.allItemsToString() {
//                var textFile = ProcessTextFile(fileName: "GroceryListItems.txt")
//                textFile.write(string: itemString)
//            }
//            
            Logger.logDetails(msg: "emptyItemCount = \(emptyItemCount)")
            
//            for measure in unitsOfMeasure {
//                print(measure)
//            }
        }
        
//        let groceryLists = GroceryList.returnAll()
//
//        for groceryList in groceryLists {
//            print("\(groceryList.name)")
//            var i = 0
//            for item in groceryList.hasItems {
//                guard let groceryListItem = item as? GroceryListItem else {
//                    return
//                }
//
//                print("\(groceryListItem.name)")
//                groceryListItem.update(listPosition: i)
//                i += 1
//            }
//        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
        addScrollAreaView()

        setupSearchHeaderViewController()

        searchString = searchTextField?.text
        
        createFetchedResultsController(searchString: searchString)

        hideSearchBar(searchHeaderViewController?.searchBar)
                
        checkCameraAndLibrary()
    }
    
    func setupSearchHeaderViewController() {
        if searchHeaderViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            resultTableViewController = storyboard.instantiateViewController(withIdentifier: "ResultsTableViewController") as? UITableViewController

            searchHeaderViewController = RecipeTableSearchHeaderViewController(nibName: "RecipeTableSearchHeaderView", bundle: nil)
            searchHeaderViewController!.view.frame = CGRect(x: 0.0, y: 0.0, width: 600.0, height: 108.0)
            searchHeaderViewController!.searchBar.delegate = self
            searchHeaderViewController!.delegate = self

            if let searchField = searchHeaderViewController!.searchBar.value(forKey: "searchField") as? UITextField {
                searchTextField = searchField
            }
            searchTextField?.addLeadingButton(title: "Dismiss", image: nil, target: self, selector: #selector(dismissKeyboard))
        }

        tableView.tableHeaderView = UIView(frame: searchHeaderViewController!.view.frame)
        tableView.tableHeaderView?.addSubview(searchHeaderViewController!.view)
        
        resultTableViewController.tableView.delegate = self
        resultTableViewController.tableView.dataSource = self
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    @IBAction func emailLogButtonPressed(_ sender: Any)
//    {
//        performSegue(withIdentifier: "EmailLogSegue", sender: self)
//    }

    @objc func dismissKeyboard() {
        searchTextField?.resignFirstResponder()
    }
    
    func addRecipeWithPathname(pathname: URL) -> Bool /*Array<String>*/ {
        let recipeFiles:RecipeFiles = RecipeFiles()
        let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        let recipeAddResult = recipeFiles.returnRecipeFromXML(recipePath: pathname.path, databaseInterface: databaseInterface)
        
        return recipeAddResult
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
//        DispatchQueue.main.async {
//            var changedFiles = 0
//            let documentsDir = FileUtilities.applicationDocumentsDirectory()
//            let inputPathnames = RecipeFiles().initializeRecipePathnames()
//            for inputPathnameFolder in inputPathnames {
//                var firstPathname = true
//                for inputPathname in inputPathnameFolder {
//                    let inputPathComponents = inputPathname.split(separator: "/")
//                    let outputFolder = String(inputPathComponents[inputPathComponents.count-2])
//                    let outputFilename = String(inputPathComponents[inputPathComponents.count-1])
//                    let outputFolderPathname = documentsDir.appendingPathComponent(outputFolder, isDirectory: true)
//                    let fileString = try! String(contentsOfFile: inputPathname)
//                    let fileLines = fileString.split(separator: "\n")
//                    var outputFileString = ""
//                    var fileModified = false
//                    for fileLine in fileLines {
//                        var finalLine = String(fileLine)
//                        if fileLine.contains("<ingredientName>") && fileLine.contains("(") {
//                            fileModified = true
//                            finalLine = fileLine.replacingOccurrences(of: "(", with: "\\(")
//                            finalLine = finalLine.replacingOccurrences(of: ")", with: "\\)")
//                          print(finalLine)
//                        }
//                        outputFileString += finalLine + "\n"
//                    }
//                  print(outputFileString)
//                    if fileModified {
//                        changedFiles += 1
//                        if firstPathname {
//                            firstPathname = false
//                            FileUtilities.createDirectory(outputFolder)
//                          print(folderPathname)
//                        }
//                        let outputPathname = outputFolderPathname.appendingPathComponent(outputFilename, isDirectory: false)
//                        print(outputFilename)
//                        try! outputFileString.write(toFile: outputPathname.path, atomically: true, encoding: .utf8)
//                    }
//                }
//            }
//            print("Changed files: \(changedFiles)")
//        }

        // Look to the bottom of the function to see where inputTextField is assigned
        var inputTextField = UITextField()

        AlertUtilities.showTextFieldAlert(viewController: self,
                                          title: "Enter recipe name\n(case-sensitive):",
                                          message: "",
                                          startingText: "",
                                          keyboardType: nil,
                                          capitalizationType: .words) { alertAction in

                let pathname = RecipeFiles().recipePathnameFromTitle(userInput: inputTextField.text!)
                print("\(pathname)")

                if Utilities.fileExistsAtAbsolutePath(pathname: pathname.path) {
                    let recipeName = RecipeFiles.returnRecipeTitleFromPath(recipeResourceFilePath: pathname.path)
                    print("Recipe name: \(recipeName)")

                    if Recipe.findRecipeByName(recipeName) != nil {
                        AlertUtilities.showOkButtonAlert(self, title: "That recipe is already in the database", message: "", buttonHandler: nil)
                    } else {
                        // If not, parse and add it
                       if self.addRecipeWithPathname(pathname: pathname) {
                           AlertUtilities.showOkButtonAlert(self, title: "Recipe added", message: "May need to restart app to see it", buttonHandler: nil)
                           self.tableView.reloadData()
                       } else {
                           AlertUtilities.showOkButtonAlert(self, title: "Error adding recipe", message: "", buttonHandler: nil)
                       }
                    }
                } else {
                    AlertUtilities.showOkButtonAlert(self, title: "Recipe file not found", message: "", buttonHandler: nil)
                }

            } textFieldHandler: { textField in
                inputTextField = textField
            }

    }
    
    @IBAction func modifyButtonPressed(_ sender: Any) {
        // Look to the bottom of the function to see where inputTextField is assigned
        var inputTextField = UITextField()

        AlertUtilities.showTextFieldAlert(viewController: self,
                                          title: "Enter recipe name\n(case-sensitive):",
                                          message: "",
                                          startingText: "",
                                          keyboardType: nil,
                                          capitalizationType: .words) { alertAction in
            
            let textFieldText = inputTextField.text!
            
            let pathname = RecipeFiles().recipePathnameFromTitle(userInput: textFieldText)
            print("\(pathname)")
            
            if Utilities.fileExistsAtAbsolutePath(pathname: pathname.path) {
                // ADD CODE HERE TO DELETE THE RECIPE FROM THE DATABASE AND RE-ADD IT USING THE CONTENTS OF THE FILE
                if let recipe = Recipe.findRecipeByName(textFieldText.trimmingCharacters(in: .whitespaces)) {
                    let databaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
                    databaseInterface.deleteObject(coreDataObject: recipe)
                    if self.addRecipeWithPathname(pathname: pathname) {
                        AlertUtilities.showOkButtonAlert(self, title: "Recipe modified", message: "May need to restart app to see changes", buttonHandler: nil)
                        self.tableView.reloadData()
                    } else {
                        AlertUtilities.showOkButtonAlert(self, title: "Error re-adding recipe", message: "", buttonHandler: nil)
                    }
                } else {
                    AlertUtilities.showOkButtonAlert(self, title: "Recipe not found in database", message: "", buttonHandler: nil)
                }
            } else {
                AlertUtilities.showOkButtonAlert(self, title: "Recipe file not found", message: "", buttonHandler: nil)
            }
        
        } textFieldHandler: { textField in
            inputTextField = textField
        }
    }
    
    @IBAction func buildButtonPressed(_ sender: Any) {
        buildRecipeDatabase()
    }
    
    func buildRecipeDatabase() {
        registerForNotifications()
        
        tableView.alpha = 0.0
        progressLabel.alpha = 1.0
        progressLabel.text = "Creating Recipe Database..."
        let recipeFiles:RecipeFiles = RecipeFiles()
        recipeFiles.initializeRecipeDatabaseFromResourceFiles()
    }

// THIS FUNCTION TAKES ALL THE Recipe FILES AND REMOVES ANY PARENTHESES FROM THE ingredientName LINES.
// Android XML PARSING ERRORS OUT ON THOSE. THE "FIXED" FILES ARE WRITTEN TO THE Application Documents Directory.
    
    @IBAction func fixPuttonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            let documentsDir = FileUtilities.applicationDocumentsDirectory()
            let inputPathnames = RecipeFiles().initializeRecipePathnames()
            for inputPathnameFolder in inputPathnames {
                var firstPathname = true
                for inputPathname in inputPathnameFolder {
                    let inputPathComponents = inputPathname.split(separator: "/")
                    let outputFolder = String(inputPathComponents[inputPathComponents.count-2])
                    let outputFilename = String(inputPathComponents[inputPathComponents.count-1])
                    let outputFolderPathname = documentsDir.appendingPathComponent(outputFolder, isDirectory: true)
                    let fileString = try! String(contentsOfFile: inputPathname)
                    let fileLines = fileString.split(separator: "\n")
                    var outputFileString = ""
                    var fileModified = false
                    for fileLine in fileLines {
                        var finalLine = String(fileLine)
                        if fileLine.contains("<ingredientName>") && fileLine.contains("(") {
                            fileModified = true
                            finalLine = fileLine.replacingOccurrences(of: "(", with: "\\(")
                            finalLine = finalLine.replacingOccurrences(of: ")", with: "\\)")
//                          print(finalLine)
                        }
                        outputFileString += finalLine + "\n"
                    }
//                  print(outputFileString)
                    if fileModified {
                        if firstPathname {
                            firstPathname = false
                            FileUtilities.createDirectory(outputFolder)
//                          print(folderPathname)
                        }
                        let outputPathname = outputFolderPathname.appendingPathComponent(outputFilename, isDirectory: false)
                        print(outputPathname)
                        try! outputFileString.write(toFile: outputPathname.path, atomically: true, encoding: .utf8)
                    }
                }
            }
        }
    }
    
    /*
    func updateGroceryListItems() {
        let databaseInterface = DatabaseInterface()
        
        let groceryListItems = GroceryListItem.fetchAll(databaseInterface: databaseInterface)
        
        guard let gListItems = groceryListItems else {
            Logger.logDetails(msg: "groceryListItems is nil")
            return
        }
        
        for groceryListItem in gListItems  {
            groceryListItem.isBought = NSNumber(value: false)
            groceryListItem.isTaxable = NSNumber(value: false)
            
            NSLog("groceryListItem = \(groceryListItem)")
       }

    }
*/
    
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
    
    func hideSearchBar(_ searchBar: UISearchBar?) {
        
// IF THE SEARCH BAR REFUSES TO HIDE, TRY RUNNING THE APP FROM THE PHONE (NOT Xcode)
// CHANCES ARE IT'S A STUPID Xcode BUG!
        
        searchBar?.resignFirstResponder()
        
        Logger.logDetails(msg: "searchBar == nil: \(searchBar == nil), self.tableView.contentOffset: \(self.tableView.contentOffset)")
        
        if self.tableView.contentOffset.y >= 0.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(10)) {
                Logger.logDetails(msg: "self.searchHeaderViewController is not nil")
                if self.searchHeaderViewController != nil {
                    self.searchHeaderViewController?.searchType = .RecipeTitle
                    self.searchHeaderViewController?.segmentedControl.selectedSegmentIndex = 0
                }
                self.tableView.contentOffset = CGPoint(x: 0.0, y: self.tableView.tableHeaderView!.frame.height)
            }
        }
    }
    
    func createFetchedResultsController(searchString:String?) {
        let databaseInterface:DatabaseInterface = DatabaseInterface(concurrencyType: .mainQueueConcurrencyType)
        
        Logger.logDetails(msg: "searchString: \(searchString ?? "nil")")
        
        if searchString != nil && !searchString!.isEmpty {
            if searchHeaderViewController != nil, searchHeaderViewController?.searchType == .Ingredient {
                fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "Recipe", sortKey: "title.indexCharacter", secondarySortKey: "title.name", sectionNameKeyPath:"title.indexCharacter", predicate:NSPredicate(format: "ANY containsIngredients.ingredientItem.name  contains[cd] %@", searchString!))
            } else {
                fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "Recipe", sortKey: "title.indexCharacter", secondarySortKey: "title.name", sectionNameKeyPath:"title.indexCharacter", predicate:NSPredicate(format: "title.name contains[cd] %@", searchString!))
            }
        }
        else {
            fetchedResultsController = databaseInterface.createFetchedResultsController(entityName: "Recipe", sortKey: "title.indexCharacter", secondarySortKey: "title.name", sectionNameKeyPath: "title.indexCharacter", predicate:nil)
        }
        
        sectionTitles = Utilities.convertSectionTitles(fetchedResultsController: fetchedResultsController)
        sectionIndexTitles = Utilities.convertSectionIndexTitles(fetchedResultsController: fetchedResultsController)
        
        fetchedResultsController.delegate = self
        tableView.reloadData()
    }

    func RecipeSearchTypeChanged(searchType: RecipeSearchType) {
        Logger.logDetails(msg: "Entered")
        createFetchedResultsController(searchString: searchString)
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
        notificationCenter.addObserver(self, selector: #selector(RecipeMasterTableViewController.handleRecipeProgressNotification(notification:)), name: NSNotification.Name(rawValue: "SwiftRecipeParser.RecipeProgressNotification"), object: nil)
    }
    
    func deregisterFromNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name(rawValue: "SwiftRecipeParser.RecipeProgressNotification"), object: nil)
    }
    
    @objc func handleRecipeProgressNotification(notification:NSNotification)
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
        tableView.reloadData()
    }
        
    func updateProgressLabel(percentage:Float)
    {
        progressLabel.text = String(format:"Creating Recipe Database: %.0f%%", percentage)
        
        if percentage == 100.0 {
            deregisterFromNotifications()
            
            progressLabel.alpha = 0.0
            tableView.alpha = 1.0
            loadRecipeTable()
            
            let totalRecipes = Recipe.countOfDatabaseRecipes()
            IToast().showToast(
                self,
                alertTitle: "\(totalRecipes) Recipes Processed",
                alertMessage: "",
                duration: TimeInterval(2),
                completionHandler: nil)
        }
    }
    
    func loadRecipeTable() {
        createFetchedResultsController(searchString: searchString)
    
        //tableView.reloadData()
    
        //Recipe.outputAllRecipesToFiles(true);
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if index == 0 {
            showSearchBar()
        }
        
        return index
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // Called before warning appears

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
        // Called before warning appears

        // Return the number of sections.
        var returnValue:Int = 0
        
        if (fetchedResultsController.sections != nil) {
            returnValue = fetchedResultsController.sections!.count + 1
        }

        Logger.logDetails(msg: "Number of sections in table view \(returnValue)")
        
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
                        if let recipe = Recipe.findRecipeByName(cell.textLabel!.text!) {
                            detailViewController.recipe = recipe
                        }
                    }
                }
            }
            else {
                let indexPath:IndexPath = tableView.indexPathForSelectedRow!
                let realIndexPath:IndexPath = IndexPath(row: indexPath.row, section: indexPath.section-1)
                
                detailViewController.recipe = fetchedResultsController.object(at: realIndexPath) as? Recipe
            }
            
            return
        }
    }

    // MARK: - Search Bar Delegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateTableWithSearchString(searchString: "")
        
        Logger.logDetails(msg: "searchString is now empty")
        
        hideSearchBar(searchBar)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        hideSearchBar(searchBar)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateTableWithSearchString(searchString: searchText)
    }

    func updateTableWithSearchString(searchString: String?) {
        Logger.logDetails(msg: "Create FetchedResultsController with searchString: \(searchString ?? "nil")")
        createFetchedResultsController(searchString: searchString)
        
        resultTableViewController.tableView.reloadData()
    }
    
    // MARK: - Scroll View Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView.contentOffset.y <= 0 && searchTextField != nil {
            searchTextField?.becomeFirstResponder()
            searchString = searchTextField?.text
            Logger.logDetails(msg: "searchString valueis now \(searchString ?? "nil")")
            updateTableWithSearchString(searchString: searchString)
        }
    }
}
