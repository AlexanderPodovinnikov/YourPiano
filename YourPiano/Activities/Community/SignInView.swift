//
//  SignInView.swift
//  YourPiano
//
//  Created by Alex Po on 01.08.2022.
//

import SwiftUI
import AuthenticationServices

struct SignInView: View {
    enum SignInStatus {
        case unknown
        case authorized
        case failure(Error?)
    }
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @State private var status = SignInStatus.unknown

    var body: some View {
        NavigationView {
            Group {
                switch status {
                case .unknown:
                    VStack(alignment: .leading) {
                        ScrollView {
                            Text("SIGN_IN_PROMPT")
                        }
                        Spacer()
                        SignInWithAppleButton(
                            onRequest: configureSignIn,
                            onCompletion: completeSignIn
                        )
                        .frame(height: 44)
                        .signInWithAppleButtonStyle(
                            colorScheme == .light
                            ? .black
                            : .white
                        )
                        Button("CANCEL", action: close)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                case .authorized:
                    Text("ALRIGHT")
                case .failure(let error):
                    if let error = error {
                        Text("SORRY_ERROR \(error.localizedDescription)")
                    } else {
                        Text("SORRY_ERROR")
                    }
                }
            }
            .padding()
            .navigationTitle("PLEASE_SIGN_IN")
        }
    }

    func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName]
    }

    func completeSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
                if let fullName = appleID.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    var userName = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
                    if userName.isEmpty {
                        // no empty usernames!
                        userName = "User-\(Int.random(in: 1001...9999))"
                    }
                    UserDefaults.standard.set(userName, forKey: "username")
                    NSUbiquitousKeyValueStore.default.set(userName, forKey: "username")
                    status = .authorized
                    close()
                    return
                }
            }
            status = .failure(nil) // WTF is going on???
        case .failure(let error):
            if let error = error as? ASAuthorizationError {
                if error.errorCode == ASAuthorizationError.canceled.rawValue {
                    status = .unknown
                    return
                }
            }
            status = .failure(error)
        }
    }

    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
