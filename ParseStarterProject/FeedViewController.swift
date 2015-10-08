//
//  FeedViewController.swift
//  ParseStarterProject
//
//  Created by Daniel Schartner on 7/21/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {
    
    var followedUsers = [NSString]()
    var posts = [AnyObject]()
    var postUserIds = [NSString]()
    var postUsernames = [NSString]()
    
    //gets usernames from userids and puts them in postUsernames
    func convertToNames(userIds: NSArray){
        let getUsers = PFUser.query()
        getUsers!.whereKey("objectId", containedIn: userIds as [AnyObject])
        //init search
        getUsers!.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let users = result{
                //the users were found so save usernames
                for object in users{
                    self.postUsernames.append(object["username"] as! NSString)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    //get the picture posts from followed users
    func getPosts(following: NSArray){
        for followedUser in following{
            let getPosts = PFQuery(className: "Posts")
            getPosts.whereKey("user", equalTo: followedUser)
            getPosts.findObjectsInBackgroundWithBlock { (result, error) -> Void in
                if let posts = result{
                    //save the entire object into posts array
                    for object in posts{
                        self.postUserIds.append(object["user"] as! NSString)
                        self.posts.append(object)
                    }
                    self.convertToNames(self.postUserIds)
                }
            }
        }
    }
    
    //find people the current user is following
    func getFollowings(){
        let getUsers = PFQuery(className: "Followers")
        getUsers.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
        getUsers.findObjectsInBackgroundWithBlock { (result, error) -> Void in
            if let followings = result{
                for object in followings{
                    self.followedUsers.append(object["following"] as! NSString)
                }
                self.getPosts(self.followedUsers)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //start going down the rabbit hole
        getFollowings()
        
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
        return posts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //create a new cell that's derived from the Cell class
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! Cell
        
        //setup cell data
        if(posts.count > 0 && postUsernames.count > 0 && postUsernames.count == posts.count){
            //download image and set to imageView
            let imageFile = posts[indexPath.row]["imageFile"] as! PFFile
            imageFile.getDataInBackgroundWithBlock({ (data, error) -> Void in
                if let unrapData = data{
                    if let downloadedImage = UIImage(data: unrapData){
                        cell.feedImage.image = downloadedImage
                    }
                }
            })
            //setup text
            cell.postDesc.text = posts[indexPath.row]["desc"] as! String
            cell.postUser.text = postUsernames[indexPath.row] as! String
        }

        // Configure the cell...

        return cell
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
