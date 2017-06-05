//
//  Authenticator
//
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Bibek Timalsina. All rights reserved.
//

import Foundation
import Firebase
import FacebookCore
import FacebookLogin

typealias CompletionBlock = (Void) -> Void
typealias CallBackWithSuccessError = (_: Bool, _: Error?) -> Void
typealias CallBackWithError = (Error?) -> ()

enum Provider: String {
    case facebook = "facebook.com"
    //    case twitter = "twitter.com"
    //    case google = "google.com"
    //    case password = "password"
}

protocol AuthenticatorDelegate {
    func didOccurAuthentication(error: AuthenticationError)
    func didSignInUser()
    func didLogoutUser()
    func shouldUserSignInIntoFirebase() -> Bool
}

enum AuthenticationError: Error {
    case facebookLoginFailed(with: Error)
    case facebookLoginCancelled
    case facebookLoginDenied
    case firebaseAuthenticationFailed(with: Error)
    case logoutFailed(with: Error)
    
    var localizedDescription: String {
        switch self {
        case .facebookLoginCancelled: return "Facebook Login cancelled."
        case .facebookLoginDenied: return "Facebook Login Denied due to age restriction. Your age must be 17+ to log in."
        case .facebookLoginFailed(with: let error): return error.localizedDescription
        case .firebaseAuthenticationFailed(with: let error): return error.localizedDescription
        case .logoutFailed(with: let error): return error.localizedDescription
        }
    }
}

class Authenticator {
    static let shared = Authenticator()
    
    var user: LocalUser?
    var facebookProfileImages:[URL] = []
    var places:[Place]?
    
    typealias ShouldSignIn = Bool
    
    var delegate: AuthenticatorDelegate?
    
    private init() {}
    
    static var isUserLoggedIn: Bool{
        return Authenticator.currentFIRUser != nil
    }
    
    func authenticateWith(provider: Provider) {
        switch provider {
        case .facebook:
            let loginManager = LoginManager()
            loginManager.logOut()
            let userPhotos = "user_photos"
            let userFriends = "user_friends"
            let userBirthDay = "user_birthday"
            // let taggableFriends = "taggable_friends"
            loginManager.logIn([.publicProfile, .custom(userPhotos), .custom(userBirthDay), .userFriends], viewController: nil) { loginResult in
                switch loginResult {
                case .failed(let error):
                    self.delegate?.didOccurAuthentication(error: .facebookLoginFailed(with: error))
                    doLog(error)
                case .cancelled:
                    self.delegate?.didOccurAuthentication(error: .facebookLoginCancelled)
                    doLog("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    
                    GlobalConstants.UserDefaultKey.userPhotosPermissionStatusFromFacebook.set(value: grantedPermissions.contains(Permission(name: userPhotos)))
                    GlobalConstants.UserDefaultKey.userFriendsPermissionStatusFromFacebook.set(value: grantedPermissions.contains(Permission(name: userFriends))) //"user_friends"
                    GlobalConstants.UserDefaultKey.userDOBPermissionStatusFromFacebook.set(value: grantedPermissions.contains(Permission(name: userBirthDay))) //"user_birthday"
                    // GlobalConstants.UserDefaultKey.taggableFriendsPermissionStatusFromFacebook.set(value: grantedPermissions.contains(Permission(name: taggableFriends)))
                    
                    GlobalConstants.UserDefaultKey.userIdFromFacebook.set(value: accessToken.userId)
                    
                    if self.delegate?.shouldUserSignInIntoFirebase() ?? false {
                        FacebookService.shared.getUserDetails(success: { (user) in
                            self.user = user
                            
                            if let dob = self.user?.profile.dateOfBirth {
                                if let age = Utilities.returnAge(ofValue: dob, format: "MM/dd/yyyy"), age > 17 {
                                   self.signInWithFirebase(credential: credential, provider: .facebook, email: nil)
                                } else {
                                    self.delegate?.didOccurAuthentication(error: .facebookLoginDenied)
                                    doLog("User login denied! Age restriction.")
                                }
                            } else {
                                self.delegate?.didOccurAuthentication(error: .facebookLoginDenied)
                                doLog("User login denied! Set birthday in your profile.")
                            }
                        }, failure: { error in
                            print(error)
                        })
                        
                    } else {
                        print("Cant sign to firebase")
                    }
                    
                    doLog("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                }
            }
        }
    }
    
    func signInWithFirebase(credential: AuthCredential, provider: Provider, email: String?) {
        Auth.auth().signIn(with: credential, completion: { (user: User?, error: Error?) -> Void in
            if let error = error {
                self.delegate?.didOccurAuthentication(error: .firebaseAuthenticationFailed(with: error))
            }else {
                if let id = Authenticator.currentFIRUser?.uid {
                    UserService().getMe(withId: id, completion: { (user, error) in
                        if let _ = error {
                            var userValue = LocalUser()
                            if let fbUser = self.user {
                                userValue = fbUser
                            }
                            userValue.id = Authenticator.currentFIRUser?.uid
                            userValue.profile.fbId = AccessToken.current?.userId
                            print("The list of photo urls are:")
                            FacebookService.shared.loadUserProfilePhotos(value: { (photoUrlString) in
                                print(photoUrlString)
                                self.facebookProfileImages.append(URL(string: photoUrlString)!)
                            }, completion: { images in
                                self.facebookProfileImages = images.flatMap({ (image) -> URL? in
                                    return URL(string: image)
                                })
                                print(self.facebookProfileImages)
                                if self.facebookProfileImages.count > 5 {
                                    for index in 5...self.facebookProfileImages.count-1 {
                                        self.facebookProfileImages.remove(at: index)
                                    }
                                }
                                userValue.profile.images = self.facebookProfileImages
                                print(userValue.profile.images)
                                self.saveUser(user: userValue)
                            }, failure: { _ in
                                if self.facebookProfileImages.count > 0 {
                                    if self.facebookProfileImages.count > 5 {
                                        for index in 5...self.facebookProfileImages.count-1 {
                                            self.facebookProfileImages.remove(at: index)
                                        }
                                    }
                                    userValue.profile.images = self.facebookProfileImages
                                }
                                self.saveUser(user: userValue)
                            })
                        } else {
                            Authenticator.shared.user = user
                            GlobalConstants.UserDefaultKey.firstTimeLogin.set(value: true)
                            self.delegate?.didSignInUser()
                        }
                    })
                } else {
                    self.delegate?.didOccurAuthentication(error: AuthenticationError.firebaseAuthenticationFailed(with: FirebaseManagerError.noUserFound))
                }
            }
        })
    }
    
    private func saveUser(user:LocalUser){
        GlobalConstants.UserDefaultKey.firstTimeLogin.set(value: true)
        UserService().saveUser(user: user, completion: { (success, error) in
            if let error = error {
                self.delegate?.didOccurAuthentication(error: AuthenticationError.firebaseAuthenticationFailed(with: error))
            } else {
                self.delegate?.didSignInUser()
            }
        })
    }
    
    func logout() {
        
        LoginManager().logOut() //facebook logout
        GlobalConstants.UserDefaultKey.firstTimeLogin.remove()
        ChatService.shared.logout()
        
        do {
            try Auth.auth().signOut()
            self.delegate?.didLogoutUser()
        }catch {
            self.delegate?.didOccurAuthentication(error: AuthenticationError.logoutFailed(with: error))
            doLog("Error \(error)")
        }
    }
    
    static func profileChangeRequest(nickname: String?, photoUrl: URL?, completion: CallBackWithError?) {
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
            changeRequest.displayName = nickname
            changeRequest.photoURL = photoUrl
            changeRequest.commitChanges(completion: completion)
        }
    }
    
    static func sendVefificationEmail(completion: CallBackWithError?) {
        Auth.auth().currentUser?.sendEmailVerification(completion: completion)
    }
    
    static func sendEmailForPasswordRecovery(email: String, completion: @escaping CallBackWithError) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    static var currentFIRUser: User? {
        return Auth.auth().currentUser
    }
    
    static func reAuthenticate(email: String, password: String, completion: CallBackWithError?) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: completion)
    }
    
    static func updatePassword(password: String, completion: CallBackWithError?) {
        Auth.auth().currentUser?.updatePassword(to: password, completion: completion)
    }
    
}
