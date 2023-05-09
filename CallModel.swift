//
//  CallModel.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 08/05/2023.
//

import Foundation
import SendBirdCalls

    /// A Structure containing app ID, access token and user information.
struct Credential: Codable {
    let appId: String
    let userId: String
    let accessToken: String?
    let nickname: String?
    let profileURL: String?
    
        /// Initializes `Credential` object with access token. The app ID and user informations are fetched from `SendBirdCall`.
    init(accessToken: String?) {
        self.init(appID: SendBirdCall.appId ?? "",
                  userID: SendBirdCall.currentUser?.userId ?? "",
                  accessToken: accessToken,
                  nickname: SendBirdCall.currentUser?.nickname,
                  profileURL: SendBirdCall.currentUser?.profileURL)
    }
    
        /// Initializes `Credential` object.
    init(appID: String, userID: String, accessToken: String?, nickname: String? = nil, profileURL: String? = nil) {
        self.appId = appID
        self.userId = userID
        self.accessToken = accessToken
        self.nickname = nickname
        self.profileURL = profileURL
    }
}
