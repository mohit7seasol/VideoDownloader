//
//  SettingModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 10/03/26.
//

import Foundation

// MARK: - SettingModel
struct SettingModel: Codable {
    let id, name, packageName: String?
    let appLink: String?
    let consoleName, videoURL, developerAccount, developedBy: String?
    let status, version, logo, fbBannerID: String?
    let fbNativeID, fbNativeBannerID, fbInterstialID, fbAdmobAlter: String?
    let bannerID, nativeID, interstialID, appopenID: String?
    let rewardID, secBannerID, secNativeID, secInterstialID: String?
    let secAppopenID, addButtonColor, afterClick, afterClickNative: String?
    let customNative, customBanner, customInterstial, customAppOpen: String?
    let exitNative, removePakageName: String?
    let jsonURL: String?
    let appType: String?
    let isFavorite, isDeleted: Bool?
    let createdBy: AtedBy?
    let createdAt, updatedAt: String?
    let v: Int?
    let extraFields: ExtraFields?
    let updatedBy: AtedBy?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name, packageName, appLink, consoleName
        case videoURL = "videoUrl"
        case developerAccount, developedBy, status, version, logo
        case fbBannerID = "fbBannerId"
        case fbNativeID = "fbNativeId"
        case fbNativeBannerID = "fbNativeBannerId"
        case fbInterstialID = "fbInterstialId"
        case fbAdmobAlter
        case bannerID = "bannerId"
        case nativeID = "nativeId"
        case interstialID = "interstialId"
        case appopenID = "appopenId"
        case rewardID = "rewardId"
        case secBannerID = "secBannerId"
        case secNativeID = "secNativeId"
        case secInterstialID = "secInterstialId"
        case secAppopenID = "secAppopenId"
        case addButtonColor, afterClick, afterClickNative, customNative, customBanner, customInterstial, customAppOpen, exitNative, removePakageName
        case jsonURL = "jsonUrl"
        case appType, isFavorite, isDeleted, createdBy, createdAt, updatedAt
        case v = "__v"
        case extraFields, updatedBy
    }
}

// MARK: - AtedBy
struct AtedBy: Codable {
    let id, name: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
    }
}

// MARK: - ExtraFields
struct ExtraFields: Codable {
    let iptv, instaAPIURL: String?
    let subCount: String?
    let api: String?
    let secNativeID, secInterstialID, menu, fullNativeID: String?
    let enjoy: String?
    let sub, inv, fav, yov: String?
    let tiv: String?
    let listen, see: String?
    let aShareName: String?
    let aShareLink: String?
    let aShareLogo: String?
    let appjson: String?
    let play, smallNative, plan, tabMenu: String?
    let rewardInter, tagTitle: String?
    let tagURL, story: String?
    let smIAPProductID, proCast, proCloseInter: String?

    enum CodingKeys: String, CodingKey {
        case iptv
        case instaAPIURL = "instaApiUrl"
        case subCount = "sub_count"
        case api
        case secNativeID = "secNativeId"
        case secInterstialID = "secInterstialId"
        case menu
        case fullNativeID = "full_NativeId"
        case enjoy, sub, inv, fav, yov, tiv, listen, see
        case aShareName = "a_share_name"
        case aShareLink = "a_share_link"
        case aShareLogo = "a_share_logo"
        case appjson, play
        case smallNative = "small_native"
        case plan
        case tabMenu = "tab_menu"
        case rewardInter = "reward_inter"
        case tagTitle = "tag_title"
        case tagURL = "tag_url"
        case story
        case smIAPProductID = "SM_IAP_ProductID"
        case proCast = "pro_cast"
        case proCloseInter = "pro_close_inter"
    }
}
