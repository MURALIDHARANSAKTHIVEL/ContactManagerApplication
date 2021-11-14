//
//  SceneDelegate.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/12/21.
//

import UIKit
import Foundation
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var coreDataManager = CoreDataManager.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard scene as? UIWindowScene != nil else { return }
        self.getCoreDataConfigure(scene)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    /// Core Data
    func coreDataSetup(_ scene: UIScene)  {
        let viewmodel = ContactDataViewModel.init(apiRepository: APIRepository.init()) /// Initial Viewmodel
        viewmodel.fetchList() // Call API
        /// To get -> publisher once ALL data Set
        viewmodel.fetchContactListPublisher.receive(on: RunLoop.main).sink {_ in
            UserManager.shared.contacts = self.coreDataManager.fetchAllData(Contacts.self)
            self.initalViewController()
        }.store(in: &viewmodel.cancelSet)
    }
    ///InitialViewcontroller
    ///Navigate Screen
    private func initalViewController() {
        let contactViewController = UIStoryboard.init(
            name: "Main",
            bundle: nil).instantiateInitialViewController() as? ContactViewController
        let navigationController = UINavigationController.init(rootViewController: contactViewController!)
        self.window?.rootViewController = navigationController
    }
    ///Mark:- Core data Configuration
    private func getCoreDataConfigure(_ scene: UIScene) {
        let list =  UserManager.shared.contacts
        if list == nil || list?.count == 0 {
            self.coreDataSetup(scene)
        } else {
            self.initalViewController()
        }
    }
}

