//
//  GoogleDriveViewController.swift
//  Bware
//
//  Created by James on 2/8/18.
//  Copyright © 2018 James. All rights reserved.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import RealmSwift

class GoogleDriveViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var signedInLabel: UILabel!
    
    private let scopes = [kGTLRAuthScopeDriveFile]
    private let service = GTLRDriveService()
    
    var fileRealm :GTLRDrive_File = GTLRDrive_File.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
    }
    
    func uploadFile()
    {
        var fileData :Data?
        var uploadParameters :GTLRUploadParameters
        
        do
        {
            let realm = try Realm()
            let realmUrlAsString = realm.configuration.fileURL?.path
            
            // for testing with dragged in pdf
            // if let path = Bundle.main.path(forResource: "white-paper", ofType: "pdf", inDirectory: "")
            if let path = realmUrlAsString
            {
                print("REALM Path == \(path)")
                fileData = FileManager.default.contents(atPath: path)
                
                let metaData = GTLRDrive_File.init()
                metaData.name = "default.realm"
                
                if let fileData = fileData
                {
                    uploadParameters = GTLRUploadParameters.init(data: fileData, mimeType: "application/octet-stream")
                    uploadParameters.shouldUploadWithSingleRequest = false
                }
                else
                {
                    print("Error")
                    Helper.showUserMessage(title: "Error Saving Realm DB", theMessage:"Can't find file to upload", theViewController: self)
                    return
                }
                
                var query :GTLRDriveQuery
                
                // just create new file each time
                query = GTLRDriveQuery_FilesCreate.query(withObject: metaData, uploadParameters: uploadParameters)
                query.fields = "id"
                
                //(GTLRServiceTicket *ticket, GTLRDrive_File *file, NSError *error)
                self.service.executeQuery(query)
                { (ticket, file, error) -> Void  in
                    //print("ticket = \(ticket)")
                    //print("error = \(error)")
                    
                    if error == nil
                    {
                        let theFile = file as? GTLRDrive_File
                        if let theFile = theFile
                        {
                            print("File ID = \(theFile.identifier ?? "unknown")")
                            Helper.showUserMessage(title: "Realm DB Saved", theMessage: "Upload Success - Check your Google Drive (default.realm) To Verify", theViewController: self)
                        }
                    }
                    else
                    {
                        Helper.showUserMessage(title: "Error Saving Realm DB", theMessage: error?.localizedDescription ?? "Try Again", theViewController: self)
                        print("Error = \(error?.localizedDescription ?? "Unknow error")")
                    }
                }
            }
            else
            {
                print("Path not found")
                Helper.showUserMessage(title: "Error Saving Realm DB", theMessage:"Can't find file to upload", theViewController: self)
                return
            }
        }
        catch
        {
            print("Error")
            Helper.showUserMessage(title: "Error Saving Realm DB", theMessage:"Can't find file to upload", theViewController: self)
        }

    }
    
    func downloadFile()
    {
        getFileList()
    }
    
    func getLatestRealmFile()
    {
        // fileRealm.identifer should be set or nil from getFileList first
        if let id = fileRealm.identifier
        {
            let query :GTLRQuery = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: id)
            service.executeQuery(query, delegate: self, didFinish: #selector(downloadResultWithTicket(ticket:finishedWithObject:error:))
            )
        }
        else
        {
            Helper.showUserMessage(title: "No Realm DB Files Found", theMessage: "Verify default.realm File Exists On Google Drive", theViewController: self)
        }
    }
    
    // result of fetching default.realm
    @objc func downloadResultWithTicket(ticket: GTLRServiceTicket,
                                               finishedWithObject result : GTLRDataObject,
                                               error : NSError?) {
        
        if let error = error {
            Helper.showUserMessage(title: "Error Retrieving Realm DB File", theMessage: error.localizedDescription, theViewController: self)
            return
        }
        
        Helper.showUserMessage(title: "Success", theMessage: "Download of file (default.realm) complete.", theViewController: self)
        
        // result.contentType = application/octet-stream
        print("result.contentType = \(result.contentType)")
        //print("\(result.data.base64EncodedString())")
        
        // need to write default.realm out and reload it
        writeDefautRealm(data: result.data)
    }
    
    func writeDefautRealm(data :Data)
    {
        // Delete existing realm file and clear realm objs
        removeRealmFileAndClearRealm()
        // write out new file
        do
        {
            let realm = try Realm()
            let realmUrlAsString = realm.configuration.fileURL?.path
 
            if let path = realmUrlAsString
            {
                FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                realm.refresh()
            }
            else
            {
                // error
                print("file path invalid")
                Helper.showUserMessage(title: "Error Writing Realm DB File", theMessage: "Path Invalid", theViewController: self)
            }
        }
        catch
        {
            Helper.showUserMessage(title: "Error Writing Realm DB File", theMessage: "Try Again", theViewController: self)
        }
        print("-----------Exit Write File---------")
    }
    
    func removeRealmFileAndClearRealm()
    {
        do
        {
            let realm = try Realm()
            let realmUrlAsString = realm.configuration.fileURL?.path
            
            // remove file and clear realm objects
            // check if file exists first
            if let path = realmUrlAsString
            {
                if FileManager.default.fileExists(atPath: path)
                {
                    try FileManager.default.removeItem(atPath: path)
                }
            }
          
            try realm.write {
                realm.deleteAll()
                print("DeleteALL() call")
            }
        }
        catch
        {
             Helper.showUserMessage(title: "Error Removing Existing Realm DB File", theMessage: "Try Again", theViewController: self)
        }
    }
    
    // List files in Drive
    func getFileList() {
        let query = GTLRDriveQuery_FilesList.query()
        query.orderBy = "createdTime desc"  //defaults to asc
        query.pageSize = 25
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(resultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    @objc func resultWithTicket(ticket: GTLRServiceTicket, finishedWithObject result : GTLRDrive_FileList, error : NSError?) {
        
        if let error = error {
            Helper.showUserMessage(title: "Error Retrieving File List", theMessage: error.localizedDescription, theViewController: self)
            return
        }
    
        if let files = result.files, !files.isEmpty {

            // * first should be newest *
            for (i,file) in files.enumerated() {
                if i == 0
                {
                    if let id = file.identifier
                    {
                        fileRealm.identifier = id
                    }
                    if let name = file.name
                    {
                        fileRealm.name = name
                    }
                    
                    getLatestRealmFile()
                    return
                }
            }
        } else {
            Helper.showUserMessage(title: "No Realm DB Files Found", theMessage: "Verify default.realm File Exists On Google Drive", theViewController: self)
            fileRealm.identifier = nil
            fileRealm.name = nil
        }
        
    }

    @IBAction func googleSignInPressed(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func uploadPressed(_ sender: UIButton) {
        
        if self.service.authorizer != nil
        {
            uploadFile()
        }
        else
        {
            Helper.showUserMessage(title: "Error: Not Logged In", theMessage: "Log in to Google Account First", theViewController: self)
        }
    }
    
    @IBAction func downloadPressed(_ sender: UIButton) {
        
        if self.service.authorizer != nil
        {
            downloadFile()
        }
        else
        {
            Helper.showUserMessage(title: "Error: Not Logged In", theMessage: "Log in to Google Account First", theViewController: self)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error
        {
            Helper.showUserMessage(title: "Authentication Error", theMessage: error.localizedDescription, theViewController: self)
            self.service.authorizer = nil
            
        } else
        {
            if let name = user.profile.name
            {
                signedInLabel.text = "Signed in as \(name)"
            }
            self.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }

}

