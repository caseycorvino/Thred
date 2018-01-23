//
//  PhotoPostTableViewController.swift
//  Thred
//
//  Created by Thred. on 12/7/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import UIKit

class PhotoPostTableViewController: UITableViewController, UITextFieldDelegate {

    var clickedPost: Post?
    var photo: UIImage?
    
    var backgroundColor: UIColor = helping.colors[0]
    
    var flagButton = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if(clickedPost?.objectId != nil){
//            postServices.getPostForId(id: (clickedPost?.objectId)!) { (pst: Post?) in
//                self.clickedPost = pst
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(clickedPost?.comments != nil){
            return 2 + clickedPost!.comments.count
        } else {
            return 2
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPost", for: indexPath) as? PhotoPostTableViewCell{
                if(clickedPost != nil){
                    cell.im.image = photo
                    cell.dateCreatedLabel.text = helping.dateToHHmm(d: clickedPost!.created)
                    cell.textView.text = clickedPost!.caption!
                    cell.likes.text = "\(clickedPost!.likes.count)"
                    
                    cell.likeBackground.backgroundColor = backgroundColor
                    
                    if !flagButton{
                        cell.flagButton.isHidden = true;
                    } else{
                        cell.flagButton.addTarget(self, action: #selector(flagButtonClicked(sender:)), for: .touchUpInside)
                    }
                    cell.likeButton.addTarget(self, action: #selector(likeButtonClicked(sender:)), for: .touchUpInside)
                    return cell;
                }
            }
        } else if (indexPath.row == 1){
            if let cell = tableView.dequeueReusableCell(withIdentifier: "WriteCommentCell", for: indexPath) as? WriteCommentTableViewCell{
                cell.postButton.addTarget(self, action: #selector(postButtonClicked(sender:)), for: .touchUpInside)
                cell.commentTextField.delegate = self
                return cell;
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell{
                cell.flagButton.tag = indexPath.row
                cell.flagButton.addTarget(self, action: #selector(commentFlagButtonClicked(sender:)), for: .touchUpInside)
                cell.commentField.text = clickedPost?.comments[indexPath.row - 2]
                return cell;
            }
        }
        return UITableViewCell()
    }
    
    @objc func postButtonClicked(sender: UIButton){
        
      UIApplication.shared.beginIgnoringInteractionEvents()
        if let cell = tableView.cellForRow(at: [0,1]) as? WriteCommentTableViewCell{
            let comment = cell.commentTextField.text!;
            if(comment.count > 0){
                if !comment.containsEmoji{
                    postServices.uploadComment(comment: comment, post: clickedPost!, view: self, completionHandler: { (post:Post) in
                        self.clickedPost = post
                        cell.commentTextField.text = ""
                        self.tableView.reloadData()
                        UIApplication.shared.endIgnoringInteractionEvents()
                    })
                } else {
                    UIApplication.shared.endIgnoringInteractionEvents()
                    helping.displayAlertOK("Invalid Comment", message: "Comments do not support emojis", view: self)
                }
            } else {
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    
    @objc func likeButtonClicked(sender: UIButton){
        if !postServices.hasLiked(likes: clickedPost!.likes){
        postServices.likePost(id: clickedPost!.objectId!) { (likeStr: String, likes:[String]) in
            if let cell = self.tableView.cellForRow(at: [0,0]) as? PhotoPostTableViewCell {
                cell.likes.text = "\(likes.count)"
                self.clickedPost?.likes = likes
            }
        }
        }
    }
    
    
    
    @objc func commentFlagButtonClicked(sender: UIButton){
        let alert = UIAlertController(title: "Flag This Post?", message: "Are you sure you want to flag this post?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField { (reason) in
            reason.text = "Reason:"
        }
        alert.addAction((UIAlertAction(title: "Flag", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            //implement flag when its up and running, no use now.
            //let reason = "Comment - \(sender.tag - 2) - \(alert.textFields![0].text)"
            /*postServices.flagAPost(objectId: self.feed[sender.tag].objectId!, reason: reason, view: self, completionHandler: { (success: Bool) in
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
    @objc func flagButtonClicked(sender: UIButton){
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //controller?.load()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 80
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
   
    


}
