//
//  FirebaseManager.swift
//  Slide
//
//  Created by bibek timalsina on 3/26/17.
//  Copyright © 2017 Bibek Timalsina. All rights reserved.
//

import Foundation
import FirebaseAuth
import FacebookCore
import FacebookLogin

typealias CompletionBlock = (Void) -> Void
typealias CallBackWithError = (Error?) -> ()

enum Provider: String {
    case facebook = "facebook.com"
    case twitter = "twitter.com"
    case google = "google.com"
    case password = "password"
}

protocol AuthenticatorDelegate {
    func didOccurAuthentication(error: AuthenticationError)
    func didSignInWithUser(user: FIRUser?)
}

enum AuthenticationError: Error {
    case facebookLoginFailed(with: Error)
    case facebookLoginCancelled
    case firebaseAuthenticationFailed(with: Error)
    case logoutFailed(with: Error)
    
    var localizedDescription: String {
        switch self {
        case .facebookLoginFailed : return "Oops! Something went wrong with facebook login."
        case .facebookLoginCancelled: return "Facebook login was cancelled."
        case .firebaseAuthenticationFailed: return "System can't authenticate the user."
        case .logoutFailed: return "System can't logout at the moment."
        }
    }
}

class Authenticator {
    var delegate: AuthenticatorDelegate?
    
    init() {}
    
    func isUserLoggedIn() -> Bool{
        return FIRAuth.auth()?.currentUser != nil
    }
    
    func authenticateWith(provider: Provider) {
        switch provider {
        case .facebook:
            let loginManager = LoginManager()
            loginManager.logOut()
            
            loginManager.logIn([.publicProfile ], viewController: nil) { loginResult in
                switch loginResult {
                case .failed(let error):
                    self.delegate?.didOccurAuthentication(error: .facebookLoginFailed(with: error))
                    doLog(error)
                case .cancelled:
                    self.delegate?.didOccurAuthentication(error: .facebookLoginCancelled)
                    doLog("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    self.signInWithFirebase(credential: credential, provider: .facebook, email: nil)
                    doLog("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                }
            }
        default: break
        }
    }
    
    func signInWithFirebase(credential: FIRAuthCredential, provider: Provider, email: String?) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) -> Void in
            if let error = error {
                self.delegate?.didOccurAuthentication(error: .firebaseAuthenticationFailed(with: error))
            }else {
                self.delegate?.didSignInWithUser(user: user)
            }
        })
    }
    
    func logout(completionHandler: CompletionBlock) {
        
        LoginManager().logOut() //facebook logout
        
        do {
            try FIRAuth.auth()?.signOut()
            completionHandler()
        }catch {
            doLog("Error")
        }
    }
    
    func unauthFromFirebase() {
        do {
            try FIRAuth.auth()?.signOut()
        }catch {
            
        }
    }
    
    
    
    func profileChangeRequest(nickname: String?, photoUrl: URL?, completion: CallBackWithError?) {
        if let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest(){
            changeRequest.displayName = nickname
            changeRequest.photoURL = photoUrl
            changeRequest.commitChanges(completion: completion)
        }
    }
    
    func sendVefificationEmail(completion: CallBackWithError?) {
        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: completion)
    }
    
    func sendEmailForPasswordRecovery(email: String, completion: @escaping CallBackWithError) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: completion)
    }
    
    func currentFIRUser() -> FIRUser {
        return FIRAuth.auth()!.currentUser!
    }
    
    func reAuthenticate(email: String, password: String, completion: CallBackWithError?) {
        let credential = FIREmailPasswordAuthProvider.credential(withEmail: email, password: password)
        FIRAuth.auth()?.currentUser?.reauthenticate(with: credential, completion: completion)
    }
    
    func updatePassword(password: String, completion: CallBackWithError?) {
        FIRAuth.auth()?.currentUser?.updatePassword(password, completion: completion)
    }
    
}
