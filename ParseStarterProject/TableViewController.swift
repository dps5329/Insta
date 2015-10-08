//
//  TableViewController.swift
//  ParseStarterProject
//
//  Created by Daniel Schartner on 7/3/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

//main page
class TableViewController: UITableViewController {
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = ["":false]
    
    var refresher: UIRefreshControl!
    
    @IBAction func logoutUser(sender: AnyObject) {
        userLoggedOut = true
        performSegueWithIdentifier("logout", sender: self)
    }
    
    
    func setupUserList(){
        //setup lists of users and followers/following
        usernames.removeAll(keepCapacity: true)
        userids.removeAll(keepCapacity: true)
        isFollowing.removeAll(keepCapacity: true)
        let query = PFUser.query()
        query!.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects{
                for object in users{
                    if let user = object as? PFUser{
                        let userId = user.objectId!
                        if userId != PFUser.currentUser()!.objectId{
                            self.usernames.append(user.username!)
                            self.userids.append(userId)
                            
                            let query = PFQuery(className: "Followers")
                            
                            if let currentUserId = PFUser.currentUser()!.objectId{
                                query.whereKey("follower", equalTo: currentUserId)
                                query.whereKey("following", equalTo: userId)
                                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                    //if the query returned something we know the user is being followed
                                    if let object = objects{
                                        if(object.count > 0){
                                            self.isFollowing[userId] = true
                                        }
                                        else{
                                            self.isFollowing[userId] = false
                                        }
                                        self.tableView.reloadData()
                                    }
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func refreshed(){
        setupUserList()
        self.refresher.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pull to refresh setup
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        //valueChanged just makes sure refresher runs whenever the view is pulled down
        refresher.addTarget(self, action: "refreshed", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        setupUserList()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = usernames[indexPath.row]
        
        //checkmarks
        if(isFollowing[userids[indexPath.row]] == true){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }

        return cell
    }
    
    //handles when a cell is tapped
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if(isFollowing[userids[indexPath.row]] == true){
            //deselect and delete from database
            isFollowing[userids[indexPath.row]] = false
            cell.accessoryType = UITableViewCellAccessoryType.None
            
            let query = PFQuery(className: "Followers")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("following", equalTo: userids[indexPath.row])
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                //if the query returned something we know the user is being followed
                if let object = objects{
                    for row in object{
                        row.deleteInBackground()
                    }
                }
            })

        }else{
            isFollowing[userids[indexPath.row]] = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            
            //setup following row
            let following = PFObject(className: "Followers")
            following["following"] = userids[indexPath.row]
            following["follower"] = PFUser.currentUser()!.objectId!
            following.saveInBackground()
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
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
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
