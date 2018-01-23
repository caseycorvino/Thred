//
//  FollowServices.swift
//  Thred
//
//  Created by Casey Corvino on 12/3/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import Foundation

public class FollowServices{
    
    var backendless = Backendless.sharedInstance()
    
    //broken
    func searchFollowers(searchText: String, userId: String, completionHandler: @escaping ([BackendlessUser])->()){
        let dataStore = backendless?.data.of(Follow.ofClass())
            let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%' AND verified = '1' AND following = '\(userId)'")
            _ = query?.setPageSize(50)//eventually set offset
            dataStore?.find(query, response: { (anyObjects: [Any]?) in
                let followerObjects = anyObjects as! [Follow]
                if(followerObjects.count == 0){
                    completionHandler([])
                }
                var whereQuery = "objectId = "
                for (index, followerObject) in followerObjects.enumerated() {
                    if(index != followerObjects.count - 1){
                        whereQuery += "'\(followerObject.follower)' OR objectId = "
                    } else {
                        whereQuery += "'\(followerObject.follower)'"
                    }
                }
                
                let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                _ = query2?.setPageSize(100).setOffset(Int32(followerObjects.count))
                
                _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                    
                    completionHandler(followUsers as! [BackendlessUser])
                    
                },//if error print error
                    error: { (fault: Fault?) in
                        print("\(String(describing: fault))")
                        completionHandler([]);
                        
                })
            }, error: { (fault: Fault?) in
                print(fault  ?? "fault")
                completionHandler([])
            })
    }
    
    //broken
    func searchFollowing(searchText: String, userId: String, completionHandler: @escaping ([BackendlessUser])->()){
        var result:[BackendlessUser] = [];
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%' AND follower = '\(userId)'")
        _ = query?.setPageSize(30)//eventually set offset
        dataStore?.find(query, response: { (anyObjects: [Any]?) in
            for user in anyObjects as! [BackendlessUser]{
                result.append(user)
            }
            completionHandler(result)
        }, error: { (fault: Fault?) in
            print(fault  ?? "fault")
            completionHandler([])
        })
        
    }
    
    
    func retrievePendingFollowers(offset: Int, view: UIViewController, completionHandler: @escaping ([BackendlessUser])->()){
        let query = DataQueryBuilder().setWhereClause("following = '\((backendless?.userService.currentUser.objectId)!)' AND verified = 'FALSE'").setSortBy(["created DESC"])
        _ = query?.setPageSize(30).setOffset(Int32(offset))
        _ = self.backendless?.data.of(Follow.ofClass()).find(query,
                                                             
                                                             response: { ( anyObjects: [Any]?) in
                                                                let followerObjects = anyObjects as! [Follow]
                                                                if(followerObjects.count == 0){
                                                                    completionHandler([])
                                                                }
                                                                var whereQuery = "objectId = "
                                                                for (index, followerObject) in followerObjects.enumerated() {
                                                                    if(index != followerObjects.count - 1){
                                                                        whereQuery += "'\(followerObject.follower)' OR objectId = "
                                                                    } else {
                                                                        whereQuery += "'\(followerObject.follower)'"
                                                                    }
                                                                }
                                                                
                                                                
                                                                let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                _ = query2?.setPageSize(100).setOffset(Int32(offset))
                                                                
                                                                _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                    
                                                                    completionHandler(followUsers as! [BackendlessUser])
                                                                    
                                                                },//if error print error
                                                                    error: { (fault: Fault?) in
                                                                        print("\(String(describing: fault))")
                                                                        completionHandler([]);
                                                                        
                                                                })
                                                                
                                                                
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([]);
        })
        
        
    }
    
    
    
    func searchForUsers(searchText: String, completionHandler: @escaping ([BackendlessUser])->()){
        var result:[BackendlessUser] = [];
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        let query = DataQueryBuilder().setWhereClause("name LIKE '%\(searchText)%'")
         _ = query?.setPageSize(30)//eventually set offset
        dataStore?.find(query, response: { (anyObjects: [Any]?) in
            for user in anyObjects as! [BackendlessUser]{
                if(user.objectId as String != self.getActiveUserId()){
                    result.append(user)
                }
            }
            completionHandler(result)
        }, error: { (fault: Fault?) in
            print(fault  ?? "fault")
            completionHandler([])
        })
    }
    
    func acceptFollower(userId:String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        
        //get follow object
        //save object
        let query = DataQueryBuilder().setWhereClause("following = '\((backendless?.userService.currentUser.objectId)!)' AND follower = '\(userId)'")
        let dataStore = self.backendless?.data.of(Follow.ofClass())
        _ = dataStore?.find(query, response: { (results: [Any]?) in
            
            if let pendingFollows = results as? [Follow] {
                
                for follow in pendingFollows{
                    follow.verified = true
                    dataStore?.save(follow, response: { _ in
                        print("accept")
                        completionHandler(true)
                    }, error: { (fault: Fault?) in
                        helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                        completionHandler(false)
                    })
                }
                
            }
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(false)
        })
        
       
        
    }
    
    func declineFollower(userId:String, view: UIViewController, completionHandler: @escaping (Bool)->()){
        let query = DataQueryBuilder().setWhereClause("following = '\((backendless?.userService.currentUser.objectId)!)' AND follower = '\(userId)'")
        let dataStore = self.backendless?.data.of(Follow.ofClass())
        _ = dataStore?.find(query, response: { (results: [Any]?) in
            
            if let pendingFollows = results as? [Follow] {
                
                for follow in pendingFollows{
                    dataStore?.remove(follow, response: { _ in
                        print("decline")
                        completionHandler(true)
                    }, error: { (fault: Fault?) in
                        helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                        completionHandler(false)
                    })
                }
                
            }
        }, error: { (fault: Fault?) in
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(false)
        })
        
        
    }
    
    
    
    func followUser(view: UIViewController, userId: String, completionHandler: @escaping(Bool) -> ()) {
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        
        let newFollow = Follow()
        newFollow.follower = "\(activeUserId)"
        newFollow.following = "\(userId)"
        
        let dataStore = backendless?.data.of(Follow.ofClass())
        dataStore?.save(newFollow, response: { (new: Any?) in
            print((new as! Follow).follower);
            completionHandler(true)
        }, error: { (fault: Fault?) in
           
            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
            completionHandler(false)
        })
    }
    
    func unFollowUser(view: UIViewController, userId: String, completionHandler: @escaping(Bool) -> ()) {
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        let dataStore = backendless?.data.of(Follow.ofClass())
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)' and follower = '\(activeUserId)'")
        dataStore?.find(query,
                        response: { (datas: [Any]?) in
                            if((datas?.count)! > 0){
                                for data in datas!{
                                    dataStore?.remove(data, response: {(num: NSNumber?) in
                                        completionHandler(true);
                                    }
                                        , error: { (fault: Fault?) in
                                            
                                            helping.displayAlertOK("Server Reported an Error", message: (fault?.detail)!, view: view)
                                            completionHandler(false)
                                    })
                                }
                            }
        },
                        error: { (fault: Fault?) in
                            print(fault ?? "fault")
                            completionHandler(false)
        })
    }
    
    
    //============get following=================
    
    func getFollowing(offset: Int, userId: String, view: UIViewController, completionHandler: @escaping ([BackendlessUser]) -> ()) -> Void {
        
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")
        
        _ = query?.setPageSize(100).setOffset(Int32(offset)).setSortBy(["created DESC"])
        _ = self.backendless?.data.of(Follow.ofClass()).find(query,
                                                                
                                                                response: { ( anyObjects: [Any]?) in
                                                                    let followerObjects = anyObjects as! [Follow]
                                                                    print("\(userId) Following: \(followerObjects.count)")
                                                                    if(followerObjects.count == 0){
                                                                        completionHandler([])
                                                                    }
                                                                    var whereQuery = "objectId = "
                                                                    for (index, followerObject) in followerObjects.enumerated() {
                                                                        if(index != followerObjects.count - 1){
                                                                            whereQuery += "'\(followerObject.following)' OR objectId = "
                                                                        } else {
                                                                            whereQuery += "'\(followerObject.following)'"
                                                                        }
                                                                    }
                                                                    
                                                                    
                                                                    let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                    _ = query2?.setPageSize(100).setOffset(0)
                                                                    
                                                                    _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                        
                                                                            completionHandler(followUsers as! [BackendlessUser])
                                                                        
                                                                    },//if error print error
                                                                        error: { (fault: Fault?) in
                                                                            print("\(String(describing: fault))")
                                                                            completionHandler([]);
                                                                            
                                                                    })
                                                            
                                                                    
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([]);
        })
        
    }
    
    //============get followers==================
    func getFollowers(offset: Int, userId: String, view: UIViewController, completionHandler: @escaping ([BackendlessUser]) -> ()) -> Void {
        
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)' AND verified = '1'").setSortBy(["created DESC"])
        _ = query?.setPageSize(100).setOffset(Int32(offset))
        _ = self.backendless?.data.of(Follow.ofClass()).find(query,
                                                             
                                                             response: { ( anyObjects: [Any]?) in
                                                                let followerObjects = anyObjects as! [Follow]
                                                                
                                                                if(followerObjects.count == 0){
                                                                    completionHandler([])
                                                                }
                                                                var whereQuery = "objectId = "
                                                                for (index, followerObject) in followerObjects.enumerated() {
                                                                    if(index != followerObjects.count - 1){
                                                                        whereQuery += "'\(followerObject.follower)' OR objectId = "
                                                                    } else {
                                                                        whereQuery += "'\(followerObject.follower)'"
                                                                    }
                                                                }
                                                                
                                                                let query2 = DataQueryBuilder().setWhereClause(whereQuery)
                                                                _ = query2?.setPageSize(100).setOffset(0)
                                                                
                                                                _ = self.backendless?.data.of(BackendlessUser.ofClass()).find(query2, response: { (followUsers: [Any]?) in
                                                                    
                                                                    
                                                                    completionHandler(followUsers as! [BackendlessUser])
                                                                    
                                                                    
                                                                },//if error print error
                                                                    error: { (fault: Fault?) in
                                                                        print("\(String(describing: fault))")
                                                                        completionHandler([]);
                                                                        
                                                                })
                                                                
                                                                
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler([]);
        })
        
    }
    
    func getActiveUserId()->String?{
        return backendless?.userService.currentUser.objectId as String?
    }
    
    func getActiveUser()->BackendlessUser?{
        return backendless?.userService.currentUser
    }
    
    //================get follower count===================//
    
    func getPendingFollowerCount (userId: String,completionHandler: @escaping (Int)->()) {
        let dataStore = self.backendless?.persistenceService.of(Follow.ofClass())
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)' AND verified = '0'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    
                                    print("Found pending follower objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknonw fault")")
                                    completionHandler(-1)
        })
    }
    
    func getFollowerCount (userId: String,completionHandler: @escaping (Int)->()) {
        let dataStore = self.backendless?.persistenceService.of(Follow.ofClass())
        let query = DataQueryBuilder().setWhereClause("following = '\(userId)' AND verified = '1'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    print("Found follower objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknonw fault")")
                                    completionHandler(-1)
        })
    }
    
    func getFollowingCount (userId: String, completionHandler: @escaping (Int)->()) {
        let dataStore = self.backendless?.persistenceService.of(Follow.ofClass())
        let query = DataQueryBuilder().setWhereClause("follower = '\(userId)'")
        dataStore?.getObjectCount(query,
                                  response: {
                                    (objectCount : NSNumber?) -> () in
                                    //print("Found following objects: \(objectCount ?? 0)")
                                    completionHandler((objectCount?.intValue) ?? 0)
        },
                                  error: {
                                    (fault : Fault?) -> () in
                                    print("Server reported an error: \(fault?.description ?? "Unknown fault")")
                                    completionHandler(-1)
        })
    }
    
    //================^get follower count===================//
    /*
    func setFollowingList(followingCount: Int, completionHandler: @escaping ([String]) -> ()){
        
        //print("okay")
        
        var followingList:[String] = [];
        
        let activeUserId = (backendless?.userService.currentUser.objectId)!
        let query = DataQueryBuilder().setWhereClause("follower = '\(activeUserId)'")
        
        _ = query?.setPageSize(100).setOffset(0)
        
        let dataStore = self.backendless?.data.of(Follow.ofClass())
        
        _ = dataStore?.find(query,
                            
                            response: { ( anyObjects: [Any]?) in
                                
                                //fill followers Array.
                                //loop throughUserObjects, get the following user id, use that id to to get backendless user, add the backednless user to activeUserFollowing
                                
                                let followerObjects = anyObjects as! [Follow]
                                for f in followerObjects{
                                    followingList.append(f.following)
                                }
                                
                                
                                
                                self.retrieveNextFollowingPage(followingList: followingList, followingCount: followingCount, query: query!, data: dataStore!, completionHandler: { (list: [String]) in
                                    completionHandler(list)
                                })
                                
                                
        },//if error print error
            error: { (fault: Fault?) in
                print("\(fault?.message ?? "fault"))")
                completionHandler(["Error"])
                
        })
        
    }
    
    
    
    func  retrieveNextFollowingPage(followingList:[String], followingCount: Int, query: DataQueryBuilder, data:IDataStore,completionHandler: @escaping ([String]) -> () ) -> Void {
        var tempList = followingList
        print("\(tempList.count) < \(followingCount) ")
        if(followingList.count < followingCount){
            
            _ = query.prepareNextPage()
            
            data.find(query, response: { (anyObjects: [Any]?) in
                let followerObjects = anyObjects as! [Follow]
                
                for f in followerObjects{
                    tempList.append(f.following)
                }
                self.retrieveNextFollowingPage(followingList: tempList, followingCount: followingCount, query: query, data: data, completionHandler: {(list: [String]) in
                    completionHandler(tempList)
                })
                
            }, error: { (fault: Fault?) in
                print(fault?.description ?? "fault")
                completionHandler(tempList)
            })
            
            
        } else {
            completionHandler(tempList)
        }
    }
     */
    
    
    
    
    
}
