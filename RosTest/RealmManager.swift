//
//  RealmManager.swift
//  RosTest
//
//  Created by Doug Mead on 1/9/18.
//  Copyright © 2018 Doug Mead. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {

    static var localRealmConfig: Realm.Configuration?
    static var localRealm: Realm? {
        guard let config = self.localRealmConfig else {
            print("Could not get config")
            return nil
        }
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error {
            print("Could not init realm. Error: \(error.localizedDescription)")
            return nil
        }
    }

    static var commonSyncRealmConfig: Realm.Configuration?
    static var commonSyncRealm: Realm? {
        guard let config = self.commonSyncRealmConfig else {
            print("Could not get config")
            return nil
        }
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error {
            print("Could not init realm. Error: \(error.localizedDescription)")
            return nil
        }
    }

    static var userSyncRealmConfig: Realm.Configuration?
    static var userSyncRealm: Realm? {
        guard let config = self.userSyncRealmConfig else {
            print("Could not get config")
            return nil
        }
        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch let error {
            print("Could not init realm. Error: \(error.localizedDescription)")
            return nil
        }
    }

    static func setupAllRealms() {

        let syncCredentials = SyncCredentials.usernamePassword(username: "test", password: "abc123", register: false)

        guard let loginUrl = URL(string: "http://localhost:9080/") else {
            print("Could not construct loginUrl")
            return
        }

        SyncUser.logIn(with: syncCredentials, server: loginUrl) { (newUserResult, error) in
            guard let newUser = newUserResult else {
                print("Error getting new user. Error: \(error?.localizedDescription ?? "")")
                return
            }

            // Save the configs, not the realm, since it should be re-created on each thread

            // Local
            guard let realmDefaultUrl = Realm.Configuration.defaultConfiguration.fileURL else {
                print("Could not get realmDefaultUrl")
                return
            }
            self.localRealmConfig = Realm.Configuration(fileURL: realmDefaultUrl)

            // Common
            guard let commonRealmSyncUrl = URL(string: "realm://localhost:9080/testCommonRealmNew") else {
                print("Could not construct commonRealmSyncUrl")
                return
            }
            let commonRealmSyncConfig = SyncConfiguration(user: newUser, realmURL: commonRealmSyncUrl)
            self.commonSyncRealmConfig = Realm.Configuration(syncConfiguration: commonRealmSyncConfig)

            // Local
            guard let userRealmSyncUrl = URL(string: "realm://localhost:9080/~/testUserRealmClean") else {
                print("Could not construct userRealmSyncUrl")
                return
            }
            let userRealmSyncConfig = SyncConfiguration(user: newUser, realmURL: userRealmSyncUrl)
            self.userSyncRealmConfig = Realm.Configuration(syncConfiguration: userRealmSyncConfig)

            // Permissions
            DispatchQueue.main.async {
                print("Explicitely on main thread")
                newUser.retrievePermissions(callback: { (permissionResults, error) in
                    guard let permissions = permissionResults else {
                        print("Could not get permissions. Error: \(error?.localizedDescription ?? "")")
                        return
                    }

                    print("Realms I have permission to")
                    permissions.forEach({ (permission) in
                        print("  - \(permission)")
                    })
                })
            }
            // Test
            print("Executing immediate test")
            self.test() // common: { empty }  userSync: { 1 }
            // Test after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                print("Executing delayed test")
                self.test() // common: { empty }  userSync: { 1 2 }
            })
            // Test Open realm
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20), execute: {
                print("Executing delayed async open test")
                self.testOpenRealm() // common: { empty }  userSync: { 1 2 3 }  // NOTE: asyncOpen for commmon NEVER CALLED!! (no error)
            })
        }
    }

    static func test() {
        self.addObject(toRealm: self.localRealm, type: "local")
        self.addObject(toRealm: self.commonSyncRealm, type: "common")
        self.addObject(toRealm: self.userSyncRealm, type: "user")
    }

    static func testOpenRealm() {
        Realm.asyncOpen(configuration: self.localRealmConfig!, callbackQueue: .main, callback: { (newRealmResult, error) in
            guard let newRealm = newRealmResult else {
                print("realm is nil. Error: \(error?.localizedDescription ?? "")")
                return
            }
            print("Test async open local")
            self.addObject(toRealm: newRealm, type: "local")
        })

        Realm.asyncOpen(configuration: self.commonSyncRealmConfig!, callbackQueue: .main, callback: { (newRealmResult, error) in
            guard let newRealm = newRealmResult else {
                print("realm is nil. Error: \(error?.localizedDescription ?? "")")
                return
            }
            print("Test async open common")
            self.addObject(toRealm: newRealm, type: "common")
        })

        Realm.asyncOpen(configuration: self.userSyncRealmConfig!, callbackQueue: .main, callback: { (newRealmResult, error) in
            guard let newRealm = newRealmResult else {
                print("realm is nil. Error: \(error?.localizedDescription ?? "")")
                return
            }
            print("Test async open user")
            self.addObject(toRealm: newRealm, type: "user")
        })
    }

    static func addObject(toRealm realm: Realm!, type: String) {
        let id = Incrementer().incrementingIndex(forKey: type)
        let obj = TestObject(id: "\(id)")
        print("Adding id: \(id) to \(type)")
        do {
            try realm.write {
                realm.add(obj)
            }
        } catch let error {
            print("Error is: \(error.localizedDescription)")
        }
    }

}
