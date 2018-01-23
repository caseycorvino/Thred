//
//  MainFeedViewController.swift
//  Thred
//
//  Created by Casey Corvino on 12/2/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

var activeUserFollowing:[String] = []
var activeUserPendingFollowing:[String] = []

let postServices = PostServices()
let helping = Helper()
let followServices = FollowServices()

class MainFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    
    var feed: [Post] = []
    var images:[UIImage?] = [UIImage?](repeating: nil, count: 1000)
    var offset = 0;
    
    @IBOutlet var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(feed.count == 0){
            return 1
        } else {
            return feed.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(feed.count == 0){
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Posts"
            return cell;
        }
        
        let post = feed[indexPath.row]
        if(post.hasImage){
           if let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPost") as! PhotoPostTableViewCell?{
                cell.textView.text = post.caption;
                cell.dateCreatedLabel.text = helping.dateToHHmm(d: feed[indexPath.row].created)
                cell.post = post
                postServices.convertComments(post: post)
                postServices.convertLikes(post: post)
                cell.likes.text = "\(post.likes.count)";
                cell.commentsButton.setTitle("Comments - \(post.comments.count)", for: .normal)
                setCellButton(cell: cell, ind: indexPath.row)
            
                cell.likeBackground.backgroundColor = helping.getColorForIndex(index: indexPath.row)
            
                cell.im.image = UIImage()
                if images[indexPath.row] != nil{
                        cell.im.image = images[indexPath.row]
                } else {
                        postServices.getPostPicAsync(postId: post.objectId!, completionHandler: { (im: UIImage?) in
                            if im != nil{
                                self.images[indexPath.row] = im
                                cell.im.image = self.images[indexPath.row]
                            }
                        })
                    }
                return cell;
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextPost") as! TextPostTableViewCell?{
                cell.textView.text = post.caption;
                cell.dateCreatedLabel.text = helping.dateToHHmm(d: feed[indexPath.row].created)
              
                cell.likeBackground.backgroundColor = helping.getColorForIndex(index: indexPath.row)
                cell.post = post
                postServices.convertComments(post: post)
                postServices.convertLikes(post: post)
                cell.likes.text = "\(post.likes.count)";
                cell.commentsButton.setTitle("Comments - \(post.comments.count)", for: .normal)
                setCellButton(cell: cell, ind: indexPath.row)
                return cell;
            }
        }
        return UITableViewCell()
    }
    
    var reloading = false;
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if(!loading && !reloading){
                loading = true;
                loadMore()
            }
        }
        //refresh on top. implement when server can handle
        let distanceFromTop = 0 - contentYoffset;
        if(distanceFromTop > 150 && !reloading){
            print("reloading")
            reloading = true
            self.load()
        }
        
    }
    
    var loading = false;
    func loadMore(){
        
        //UIApplication.shared.beginIgnoringInteractionEvents()
            postServices.retrievePosts(offset: self.offset, view: self, completionHandler: { (posts: [Post]) in
            //reload data
                //self.offset += 15;
                var delete:[Post] = []
                if(posts.count > 0){
                    var newPosts:[Post] = []
                    for p in posts{
                        if !postServices.isExpired(created: p.created){
                            newPosts.append(p)
                        } else {
                            
//                            while(!postServices.deleting){
//                                sleep(1)
//                            }
                            delete.append(p)
                            
                            
                            //self.offset -= 1;//maybe do this
                        }
                    }
                    
                       
                        self.deleteFromArray(arr: delete)
                        
                    
                    print("OLD FEED: \(self.feed.count)")
                    
                    
                    self.feed += newPosts
                    print("NEW FEED: \(self.feed.count)")
                    self.offset += newPosts.count;
                    self.tableView.reloadData()
                    //set timeout
                    let delayInSeconds = 5.0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                        self.loading = false;
                    }
                } else{
                    print("No More Posts")
                }
            })
        
    }
    
    func deleteFromArray(arr: [Post]){
        var delete = arr;
        if(!delete.isEmpty){
          
            postServices.deleteExpiredPost(hasImage: delete[0].hasImage, post: delete[0], completionHandler: {
                delete.remove(at: 0)
                self.deleteFromArray(arr: delete)
            })
        }
    }
    
    func setCellButton(cell: PhotoPostTableViewCell, ind: Int){
        if(cell.post != nil){
            cell.flagButton.tag = ind
            cell.likeButton.tag = ind
            cell.commentsButton.tag = ind
            
            cell.flagButton.addTarget(self, action: #selector(flagButtonClicked(sender:)), for: .touchUpInside)
            cell.likeButton.addTarget(self, action: #selector(likeButtonClicked(sender:)), for: .touchUpInside)
            cell.commentsButton.addTarget(self, action: #selector(commentsButtonClicked(sender:)), for: .touchUpInside)
        }
    }
    func setCellButton(cell: TextPostTableViewCell, ind: Int){
        cell.flagButton.tag = ind
        cell.likeButton.tag = ind
        cell.commentsButton.tag = ind
        
        cell.flagButton.addTarget(self, action: #selector(flagButtonClicked(sender:)), for: .touchUpInside)
        cell.likeButton.addTarget(self, action: #selector(likeButtonClicked(sender:)), for: .touchUpInside)
        cell.commentsButton.addTarget(self, action: #selector(commentsButtonClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func flagButtonClicked(sender: UIButton){
        print("flag")
        let alert = UIAlertController(title: "Flag This Post?", message: "Are you sure you want to flag this post?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (reason) in
            reason.text = "Reason:"
        }
        alert.addAction((UIAlertAction(title: "Flag", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            //implement flag when its up and running, no use now.
            //let reason = alert.textFields![0]
            /*postServices.flagAPost(objectId: self.feed[sender.tag].objectId!, reason: reason.text!, view: self, completionHandler: { (success: Bool) in
                if(success){
             
                }else{
                    
                }
            })*/
        })))
        alert.addAction((UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @objc func commentsButtonClicked(sender: UIButton){
        print("comments")
        
        let clickedPost = feed[sender.tag]
        if clickedPost.hasImage{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoPost") as? PhotoPostTableViewController{
                vc.clickedPost = clickedPost
                vc.photo = images[sender.tag]
                vc.backgroundColor = helping.getColorForIndex(index: sender.tag)
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "TextPost") as? TextPostTableViewController{
                vc.clickedPost = clickedPost
                vc.backgroundColor = helping.getColorForIndex(index: sender.tag)
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    @objc func likeButtonClicked(sender: UIButton){
        let post = feed[sender.tag]
        if !postServices.hasLiked(likes: post.likes){
        postServices.likePost(id: post.objectId!) { (likeStr: String, likes:[String]) in
            if let cell = self.tableView.cellForRow(at: [0,sender.tag]) as? TextPostTableViewCell {
                cell.likes.text = "\(likes.count)";
                self.feed[sender.tag].likes = likes
            } else if let cell = self.tableView.cellForRow(at: [0,sender.tag]) as? PhotoPostTableViewCell {
                cell.likes.text = "\(likes.count)";
                self.feed[sender.tag].likes = likes
            }
            }
        }
    }
    let progressHUD = ProgressHUD(text: "Refreshing")
    @IBOutlet var addPostButton: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        controller = self;
        helping.putBorderOnButton(buttonView: addPostButton, radius: 50)
        
        
        // Do any additional setup after loading the view.self.view.addSubview(progressHUD)
        self.view.addSubview(progressHUD)
        load()
    }
    override func viewWillAppear(_ animated: Bool) {
        //reload data if posted (not if following changed, anonyminity). did in disapper instead
    }

    @IBAction func addPostButtonClicked(_ sender: Any) {
        
        helping.pushViewControllerAnimated(nav: navigationController, story: storyboard, identifier: "Compose")
    }
    
    func load(){
        self.loading = false
        progressHUD.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
        offset = 0;
        images = [UIImage?](repeating: nil, count: 1000)
        postServices.getFollowingCountForActiveUserFollowingList(userId: postServices.getActiveUserId()!) { (count:Int) in
            postServices.setActiveUserFollowingList(followingCount: count, completionHandler: { (users:[String], pending:[String]) in
                activeUserFollowing = users;
                activeUserPendingFollowing = pending;
                print(activeUserFollowing)
                
                postServices.retrievePosts(offset: self.offset, view: self, completionHandler: { (posts: [Post]) in
                    //reload data
                    var newPosts:[Post] = []
                    var delete: [Post]=[]
                    for p in posts{
                        if !postServices.isExpired(created: p.created){
                            newPosts.append(p)
                        } else {
                            delete.append(p)
                            //self.offset -= 1;//maybe do this
                        }
                    }
                    
                    
                    self.deleteFromArray(arr: delete)
                    
                    self.offset += newPosts.count;
                    self.feed = newPosts
                    self.tableView.reloadData()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.progressHUD.hide()
                    //do when server can handle
                    let delayInSeconds = 5.0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                        self.reloading = false;
                    }
                })
                
            })
        }
    }
    
    @IBAction func menuButtonClicked(_ sender: Any) {
        //moveIn settings
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController{
            let x: CGFloat = (-250)
            let y  = vc.view.frame.origin.y
            let height = vc.view.frame.size.height
            let width = vc.view.frame.size.width
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.view.isHidden = true;
            self.present(vc, animated: false, completion: {
                vc.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
                vc.view.isHidden = false
                //vc.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
                self.moveForMenu()
                UIView.animate(withDuration: 0.5) {
                    vc.view.frame = CGRect.init(x: x + 250, y: y, width: width, height: height)
                }
            })
        }
        
    }
    
    
    
    func moveForMenu(){
        let x = view.frame.origin.x + 250
        let y  = view.frame.origin.y
        let height = view.frame.size.height
        let width = view.frame.size.width
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }
    }
    func moveBackForMenu(){
        let x = view.frame.origin.x - 250
        let y  = view.frame.origin.y
        let height = view.frame.size.height
        let width = view.frame.size.width
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect.init(x: x, y: y, width: width, height: height)
        }
    }
}
