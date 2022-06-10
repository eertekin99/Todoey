//
//  AppDelegate.swift
//  Todoey

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "NULL")

        //Testing if Realm throws error
        do {
            _ = try Realm()
        } catch {
            print("Error: \(error)")
        }
        
        return true
    }

}

