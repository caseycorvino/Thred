//
//  MyPostsTableViewController.swift
//  Thred
//
//  Created by Thred. on 12/9/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class MyPostsTableViewController: UITableViewController {

    var feed: [Post] = []
    var images:[UIImage?] = [UIImage?](repeating: nil, count: 1000)
    var offset = 0;
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let alert = UIAlertController(title: "Delete This Post?", message: "Are you sure you want to delete this post?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction((UIAlertAction(title: "No", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
            })))
            alert.addAction((UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                alert.dismiss(animated: true, completion: nil)
                postServices.deletePost(hasImage: self.feed[indexPath.row].hasImage,objectId: self.feed[indexPath.row].objectId!, view: self, completionHandler: {(success: Bool) in
                    if(success){
                        self.feed.remove(at: indexPath.row)
                        self.images.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                        tableView.reloadData()
                    }
                })
            })))
           self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(feed.count == 0 ){
            return 1;
        }
        return feed.count + 1;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if feed.count == 0{
            let cell = UITableViewCell()
            cell.textLabel?.text = "No Posts"
            return cell
        }
        
        
        if indexPath.row == feed.count {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "deleteCell"){
                return cell}
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
                cell.likeBackground.backgroundColor = helping.getColorForIndex(index: indexPath.row)
                
                setCellButton(cell: cell, ind: indexPath.row)
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
                cell.post = post
                cell.likeBackground.backgroundColor = helping.getColorForIndex(index: indexPath.row)
                
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
    
    
    func setCellButton(cell: PhotoPostTableViewCell, ind: Int){
        if(cell.post != nil){
            cell.flagButton.isHidden = true
            cell.likeButton.tag = ind
            cell.commentsButton.tag = ind
            cell.likeButton.addTarget(self, action: #selector(likeButtonClicked(sender:)), for: .touchUpInside)
            cell.commentsButton.addTarget(self, action: #selector(commentsButtonClicked(sender:)), for: .touchUpInside)
        }
    }
    func setCellButton(cell: TextPostTableViewCell, ind: Int){
       cell.flagButton.isHidden = true
        cell.likeButton.tag = ind
        cell.commentsButton.tag = ind
        cell.likeButton.addTarget(self, action: #selector(likeButtonClicked(sender:)), for: .touchUpInside)
        cell.commentsButton.addTarget(self, action: #selector(commentsButtonClicked(sender:)), for: .touchUpInside)
    }
    
    @objc func commentsButtonClicked(sender: UIButton){
        print("comments")
        
        let clickedPost = feed[sender.tag]
        if clickedPost.hasImage{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoPost") as? PhotoPostTableViewController{
                vc.flagButton = false
                vc.clickedPost = clickedPost
                vc.photo = images[sender.tag]
                vc.backgroundColor = helping.getColorForIndex(index: sender.tag)
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "TextPost") as? TextPostTableViewController{
                vc.flagButton = false
                vc.clickedPost = clickedPost
                vc.backgroundColor = helping.getColorForIndex(index: sender.tag)
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    @objc func likeButtonClicked(sender: UIButton){
        let post = feed[sender.tag]
        
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
    
    func load(){
        progressHUD.show()
        UIApplication.shared.beginIgnoringInteractionEvents()
        offset = 0;
        images = [UIImage?](repeating: nil, count: 1000)
        
        //retruve posts for id of active user
        postServices.retrieveMyPosts(offset: self.offset, view: self, completionHandler: { (posts: [Post]) in
                    //reload data
                    self.offset += 15;
                    self.feed = posts
                    self.tableView.reloadData()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.progressHUD.hide()
                    //do when server can handle
                    //                    let delayInSeconds = 5.0
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    //                        self.reloading = false;
                    //                    }
        })
        
    }
    
    
    let progressHUD = ProgressHUD(text: "Refreshing")
    @IBOutlet var addPostButton: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        // Do any additional setup after loading the view.self.view.addSubview(progressHUD)
        self.view.addSubview(progressHUD)
        load()
    }
    
    
}
