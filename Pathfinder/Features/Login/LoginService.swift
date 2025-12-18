import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import UIKit

final class AuthService {

    static let shared = AuthService()
    private init() {}

    private var currentNonce: String?

    func loginWithEmail(
            email: String,
            password: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.saveUserToFirestore()
                    completion(.success(()))
                }
            }
        }
    
    func signInWithGoogle(
        rootVC: UIViewController,
        completion: @escaping (Bool) -> Void
    ) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(false)
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if error != nil {
                completion(false)
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                completion(false)
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { _, error in
                if error != nil {
                    completion(false)
                    return
                }

                self.saveUserToFirestore()
                completion(true)
            }
        }
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
        request.requestedScopes = [.fullName, .email]
    }

    func handleAppleLogin(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard
                let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let tokenString = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else { return }

            let firebaseCredential = OAuthProvider.appleCredential(
                withIDToken: tokenString,
                rawNonce: nonce,
                fullName: credential.fullName
            )

            Auth.auth().signIn(with: firebaseCredential) { _, error in
                if error == nil {
                    self.saveUserToFirestore()
                }
            }

        case .failure:
            break
        }
    }

    private func saveUserToFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        let ref = Firestore.firestore()
            .collection("users")
            .document(user.uid)

        ref.getDocument { snapshot, _ in
            if snapshot?.exists == true {
                ref.updateData(["lastLogin": Timestamp()])
            } else {
                ref.setData([
                    "uid": user.uid,
                    "email": user.email ?? "",
                    "name": user.displayName ?? "",
                    "provider": user.providerData.first?.providerID ?? "",
                    "createdAt": Timestamp(),
                    "lastLogin": Timestamp()
                ])
            }
        }
    }

    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let random: UInt8 = {
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }()

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
}
