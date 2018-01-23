//
//  PostServices.swift
//  Thred
//
//  Created by Casey Corvino on 12/5/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import Foundation
import CoreData



public class PostServices{
    
    var backendless = Backendless.sharedInstance()
    
    func isExpired(created: Date)->Bool{
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        if created < twoDaysAgo {
            return true
        }
        return false
    }
    
    

    func deleteExpiredPost(hasImage: Bool, post: Post, completionHandler: @escaping ()->()){
    
        
        let dataStore = backendless?.data.of(Post.ofClass())
        dataStore?.remove(byId: (post.objectId)! as String, response: { (num: NSNumber?) in
          
            self.backendless?.data.of(BackendlessUser.ofClass()).find(byId: (post.ownerId)!, response: { (res: Any?) in
                if let user = res as? BackendlessUser!{
                    
                    var likes = user.getProperty("likes")! as! Int
                    var posts = user.getProperty("posts")! as! Int
                    postServices.convertLikes(post: post)
                    likes += post.likes.count;
                    
                    posts += 1;
                    user.setProperty("likes", object: likes)
                    user.setProperty("posts", object: posts)
                    if(likes != 0 && posts != 0){
                        followServices.getFollowerCount(userId: (post.ownerId)!, completionHandler: { (followerCount: Int) in
                            if(followerCount != 0){
                                user.setProperty("rating", object: likes * 100/posts/followerCount)
                               
                                self.backendless?.userService.update(user, response: { (newuser: BackendlessUser?) in
                                    
                                    
                                    completionHandler()
                                    
                                    
                                }, error: { (fault: Fault?) in
                                    print((fault?.message)!)
                                    completionHandler()
                                  
                                })
                                
                            }
                        })
                    } else {
                        self.backendless?.userService.update(user, response: { (newuser: BackendlessUser?) in
                            
                            
                                completionHandler()
                            
                            
                        }, error: { (fault: Fault?) in
                            print((fault?.message)!)
                            completionHandler()
                        })
                        
                    }
                }
                
            }, error: { (fault: Fault?) in
                print("server reported an error \((fault?.message)!)")
                completionHandler()
            })
            
            if(hasImage){
                self.backendless?.fileService.remove(
                    "PostPics/\((post.objectId)!).jpeg",
                    response: { ( result: Any?) -> () in
                        print("Post Photo deleted")
                        
                    },
                    error: { ( fault : Fault?) -> () in
                        print("Server Reported an Error: \((fault?.detail)!)")
                        
                       
                    }
                )
                
            }
        }, error: { (fault: Fault?) in
            print("Server Reported an Error: \((fault?.detail)!)")
            completionHandler()
        })
    }
    
    func deletePost(hasImage: Bool, objectId: String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        let dataStore = backendless?.data.of(Post.ofClass())
        dataStore?.remove(byId: objectId,
                response: {(num : NSNumber?) -> () in
                                //success
                    if(hasImage){
                    self.backendless?.fileService.remove(
                        "PostPics/\(objectId).jpeg",
                        response: { ( result: Any?) -> () in
                                completionHandler(true)
                            },
                        error: { ( fault : Fault?) -> () in
                            print("Server Reported an Error: \((fault?.detail)!)")
                            //but should add to some other list to be deleted when possible
                            completionHandler(true)//even if photo not deleted, just becasue the post wont load still
                    }
                        )
                        
                    }
                    else {
                        completionHandler(true)
                    }
                    
                }, error: { (fault : Fault?) -> () in
                    helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                    completionHandler(true)
            })
    }
    
    
    
    
    func retrieveMyPosts(offset: Int, view: UIViewController, completionHandler: @escaping([Post])->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        let whereQuery = "ownerId = '\(activeUserId)'"
        let query = DataQueryBuilder().setWhereClause(whereQuery)
        _ = query?.setPageSize(15).setOffset(Int32(offset)).setSortBy(["created DESC"])
        _ = self.backendless?.data.of(Post.ofClass()).find(query,
                                                           response: { ( posts: [Any]?) in
                                                            //remove post if expired psuedo code
                                                            if let feed = posts as? [Post]{//change to var when implement expired
//                                                                    for (i, post) in feed.enumerated() {
//                                                                        if(self.isExpired(created: post.created)){
//                                                                            feed.remove(at: i)
//                                                                            self.deleteExpiredPost(hasImage: post.hasImage, objectId: post.objectId!)
//                                                                        }
//
//                                                                    }
//
                                                                completionHandler(feed)
                                                            } else {
                                                                completionHandler([])
                                                            }
                                                            
                                                            
                                                            
                                                            completionHandler(posts as! [Post])
        },
                                                           error: { (fault: Fault?) in
                                                            print("\(String(describing: fault))")
                                                            
                                                            helping.displayAlertOK("Unable to Load Feed", message: (fault?.detail)!, view: view)
                                                            completionHandler([])
        })
        
    }
    
    func uploadComment(comment: String, post: Post, view: UIViewController, completionHandler: @escaping (Post)->()) {
        //should get most updated post
        if post.commentsStr == nil || post.commentsStr == ""{
            post.commentsStr =  "\(comment)"
        } else {
            let temp = post.commentsStr!
            post.commentsStr? =  "\(comment)'|'" + temp
        }
        let dataStore = backendless?.data.of(Post.ofClass())
        dataStore?.save(post, response: { (pst: Any?) in
            if let newPost = pst as? Post{
                self.convertComments(post: newPost)
                completionHandler(newPost)
            }
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(post)
        })
        
    }
    
    //when comment is own object, later when server bigger
    /*
    func uploadComment(comment: String, postId: String, view: UIViewController, completionHandler: @escaping (Comment)->()){
        let owner = (backendless?.userService.currentUser.objectId)!
        let newCom = Comment()
        newCom.comment = comment
        newCom.postId = postId
        
        let dataStore = backendless?.data.of(Comment.ofClass())
        dataStore?.save(newCom, response: { (pst: Any?) in
            if let newCom = com as? Comment{
                completionHandler(newCom)
            }
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(newCom)
        })
     
    }*/
    
    func convertComments(post: Post){
        if post.commentsStr != nil{
            let arr = post.commentsStr?.components(separatedBy: "'|'")
            post.comments = arr!;
        }
    }
    
    func convertLikes(post: Post){
        if post.likesStr != nil{
            let arr = post.likesStr?.components(separatedBy: "'|'")
            post.likes = arr!;
        }
    }
    func convertLikesToStr(post: Post){
        var str = "";
        for p in post.likes{
            if str == ""{
                str +=  p
            } else {
                str += "'|'\(p)"
            }
        }
        post.likesStr = str
    }
    
    func flagAPost(objectId: String, reason: String, view: UIViewController, completionHandler: @escaping(Bool)->()){
        
        let flag = Flag()
        flag.flaggedId = objectId
        flag.reason = reason
        
        let dataStore = backendless?.data.of(Flag.ofClass())
        dataStore?.save(flag, response: { (any:Any?) in
            helping.displayAlertOK("Success", message: "The post was succesfully flagged. Thred will investigate further", view: view)
            completionHandler(true)
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(false)
            
        })
        
            
    }
    
    func hasLiked(likes: [String])->Bool{
        return likes.contains((backendless?.userService.currentUser.objectId)! as String)
    }
    
    func uploadPost(caption: String, image: UIImage?, view: UIViewController, completionHandler: @escaping(Bool)->()){
        
        let post = Post()
        post.caption = caption;
        if(image != nil){
            post.hasImage = true;
        }
        let dataStore = backendless?.data.of(Post.ofClass())
        dataStore?.save(post, response: { (pt : Any?) in
            
            if(image == nil){
                helping.displayAlertOKThenPop("Success", message: "Post uploaded successfully!", view: view)
                completionHandler(true)
            } else {
                if let post: Post = pt as? Post{
                    self.uploadPostPic(postIm: image!, postId: post.objectId!, view: view, completionHandler: { (success:Bool) in
                        if success{
                            helping.displayAlertOKThenPop("Success", message: "Post uploaded successfully!", view: view)
                            completionHandler(true)
                        } else{
                            
                        }
                    })
                } else{
                    helping.displayAlertOK("Server Reported an Error", message: "Unable to upload the photo", view: view)
                    completionHandler(false)
                }
                
            }
        }, error: { (fault: Fault?) in
            
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(false)
        })
    }
    
    func getPostForId(id: String, completionHandler: @escaping(Post?)->()){
        let dataStore = backendless?.data.of(Post.ofClass())
        dataStore?.find(byId: id, response: { (pst: Any?) in
            completionHandler(pst as? Post)
        }, error: { (fault:Fault?) in
            completionHandler(nil)
        })
    }
    
    //TODO Add object id to and array [String] save in coredata so dont like twice, before asynchrous task, if unsuccesul in task remove from array so can like again
    
    func likePost(id: String, completionHandler: @escaping(String, [String])->()) {
        let likerId = (backendless?.userService.currentUser.objectId)!//activeUserId
        getPostForId(id: id) { (post:Post?) in
            let dataStore = self.backendless?.data.of(Post.ofClass())
            
            if post?.likesStr == nil || post?.commentsStr == ""{
                post?.likesStr =  "\(likerId)"
            } else {
                post?.likesStr = (post?.likesStr)! + "'|'\(likerId)"
            }
            dataStore?.save(post, response: { (pst: Any?) in
                if let post = pst as? Post{
                    self.convertLikes(post: post)
                    completionHandler(post.likesStr!, post.likes)
                } else {
                    completionHandler("", [])
                }
            }, error: { (fault:Fault?) in
                completionHandler("", [])
            })
        }
    }
    
    func unlikePost(id: String, completionHandler: @escaping(String, [String])->()) {
        let likerId = (backendless?.userService.currentUser.objectId)!//activeUserId
        getPostForId(id: id) { (post:Post?) in
            let dataStore = self.backendless?.data.of(Post.ofClass())
            self.convertLikes(post: post!)
            if let ind = post?.likes.index(of: likerId as String){
                post?.likes.remove(at: ind)
                self.convertLikesToStr(post: post!)
            dataStore?.save(post, response: { (pst: Any?) in
                if let post = pst as? Post{
                    self.convertLikes(post: post)
                    completionHandler(post.likesStr!, post.likes)
                } else {
                    completionHandler("", [])
                }
            }, error: { (fault:Fault?) in
                completionHandler("", [])
            })
            }
        }
    }
    
    
    
    func uploadPostPic(postIm: UIImage, postId: String, view:UIViewController, completionHandler: @escaping(Bool)->()) -> Void{
                print("\n============ Uploading picture with the ASYNC API ============")
        let compressedPic = postIm.resize(width: 800)
                let data = UIImageJPEGRepresentation(compressedPic!, 1)
                backendless?.file.saveFile("PostPics/\(postId).jpeg", content: data! as Data, overwriteIfExist: true, response: { (file: BackendlessFile?) in
                        print("Upload Succesful. File URL is - \(file?.fileURL ?? "PATH ERROR")")
                        completionHandler(true)
                }, error: { (fault: Fault?) in
                    print("Error: \(fault?.description ?? "Unknown Fault")")
                    
                    helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                    completionHandler(false)
                })
    }
    
    
    func getPostPicAsync(postId: String, completionHandler: @escaping (UIImage?)->()){
        let url = URL(string: "https://api.backendless.com/87A275B6-E49B-9514-FF45-B2487622DC00/24AF042B-1A36-C991-FFB7-DF7952895400/files/PostPics/\(postId).jpeg")
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url!){ //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    let im = UIImage(data: data)
                    if(im != nil){
                        completionHandler(im!)
                    } else {
                        completionHandler(nil)
                    }
                }} else {
                completionHandler(nil)
            }
        }
    }
    
    func retrievePosts(offset: Int, view: UIViewController, completionHandler: @escaping([Post])->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        var whereQuery = "ownerId = '\(activeUserId)'"
        for (_, user) in activeUserFollowing.enumerated() {
                whereQuery += " OR ownerId = '\(user)'"
        }
        
            let query = DataQueryBuilder().setWhereClause(whereQuery)
        
            
            _ = query?.setPageSize(15).setOffset(Int32(offset)).setSortBy(["created DESC"])
            _ = self.backendless?.data.of(Post.ofClass()).find(query,
                                                               response: { ( posts: [Any]?) in
                                                                
                                                                //remove post if expired psuedo code
                                                                if let feed = posts as? [Post]{//change to var when implement expired
                                                                    completionHandler(feed)
                                                                } else {
                                                                    completionHandler([])
                                                                }
            },
                error: { (fault: Fault?) in
                    print("\(String(describing: fault))")
                   
                    helping.displayAlertOK("Unable to Load Feed", message: (fault?.detail)!, view: view)
                    completionHandler([])
            })
        
    }
    
    /*func getFeedPostsCount(offset: Int, view: UIViewController, completionHandler: @escaping(Int)->()){
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        var whereQuery = "ownerId = '\(activeUserId)'"
        for (_, user) in activeUserFollowing.enumerated() {
            whereQuery += " OR ownerId = '\(user)'"
        }
        
        _ = DataQueryBuilder().setWhereClause(whereQuery)
        self.backendless?.data.of(Post.ofClass()).getObjectCount({ (cnt: NSNumber?) in
            if let count = cnt as? Int{
                completionHandler(count)
            } else {
                completionHandler(0)
            }
        }, error: { (fault: Fault?) in
            print((fault?.message)!)
        })
    }*/
    
    
    
    
    func getFollowingCountForActiveUserFollowingList(userId: String, completionHandler: @escaping (Int)->()) {
        let dataStore = self.backendless?.persistenceService.of(Follow.ofClass())
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")//AND VERIFIED = TRUE
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    print("Found following objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                    completionHandler(-1)
        })
    }
    
    func setActiveUserFollowingList(followingCount: Int, completionHandler: @escaping ([String],[String]) -> ()){
        
        //print("okay")
        
        var followingList:[String] = [];
        var pendingList:[String] = [];
        
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        let query = DataQueryBuilder().setWhereClause("follower = '\(activeUserId)'")//AND VERIFIED = TRUE
        
        _ = query?.setPageSize(100).setOffset(0)
        
        let dataStore = self.backendless?.data.of(Follow.ofClass())
        
        _ = dataStore?.find(query,
                            
                            response: { ( anyObjects: [Any]?) in
                                
                                //fill followers Array.
                                //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                
                                
                                
                                let followerObjects = anyObjects as! [Follow]
                                for f in followerObjects{
                                    
                                    
                                    print(f.verified)
                                    if(f.verified){
                                        followingList.append(f.following)
                                    } else {
                                        pendingList.append(f.following)
                                    }
                                    
                                }
                                
                                
                                self.retrieveNextFollowingPage(followingList: followingList, pendingList: pendingList, followingCount: followingCount, query: query!, data: dataStore!, completionHandler: { (list: [String], pending: [String]) in
                                    completionHandler(list, pending)
                                })
                                
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([], [])
                
        })
        
    }
    func  retrieveNextFollowingPage(followingList:[String], pendingList: [String], followingCount: Int, query: DataQueryBuilder, data:IDataStore,completionHandler: @escaping ([String],[String]) -> () ) -> Void {
        var tempList = followingList
        var tempPending = pendingList
        print("\(tempList.count + tempPending.count) < \(followingCount) ")
        if((followingList.count + pendingList.count) < followingCount){
            
            _ = query.prepareNextPage()
            
            data.find(query, response: { (anyObjects: [Any]?) in
                let followerObjects = anyObjects as! [Follow]
                
                for f in followerObjects{
                    
                    if(f.verified){
                         tempList.append(f.following)
                    } else {
                        tempPending.append(f.following)
                    }
                    
                }
                self.retrieveNextFollowingPage(followingList: tempList, pendingList: tempPending, followingCount: followingCount, query: query, data: data, completionHandler: {(list: [String], pending: [String]) in
                    completionHandler(tempList, tempPending)
                })
                
            }, error: { (fault: Fault?) in
                print(fault?.description ?? "fault")
                completionHandler(tempList, tempPending)
            })
            
            
        } else {
            completionHandler(tempList, tempPending)
        }
    }
    
    func getActiveUserId()->String?{
        return backendless?.userService.currentUser.objectId as String?
    }
    
}

extension UIImage {
    func resize(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
