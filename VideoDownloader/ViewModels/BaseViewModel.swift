//
//  BaseViewModel.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI
import Combine
import MapKit

class BaseViewModel: NSObject, ObservableObject {
    
    static var shared = BaseViewModel()

//    var isLoading = false
//
//    func startLoading(){
//        isLoading = true
//    }
//
//    func stopLoading(){
//        isLoading = false
//    }
    
    func haptic(){
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
    }
    

    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    func openAppleMapsForDirections(to mapItem: MKMapItem) {
            let destination = mapItem
            
            let launchOptions: [String: Any] = [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                MKLaunchOptionsShowsTrafficKey: true
            ]
            
            destination.openInMaps(launchOptions: launchOptions)
        }

    func callPhoneNumber(_ phone: String) {
            // Remove spaces & special chars
            let cleaned = phone
                .components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()

            guard let url = URL(string: "tel://\(cleaned)"),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }

            UIApplication.shared.open(url)
        }

        func shareCinema(_ cinema: MKMapItem) {
            var items: [Any] = []
            
            if let name = cinema.name {
                items.append(name)
            }
            
            if let address = cinema.placemark.title {
                items.append(address)
            }
            
            if let url = cinema.url {
                items.append(url)
            } else {
                // fallback Apple Maps link
                let coordinate = cinema.placemark.coordinate
                let mapsURL = URL(
                    string: "http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)"
                )!
                items.append(mapsURL)
            }
            
            let controller = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                root.present(controller, animated: true)
            }
        }
    
    func shareItem(_ item: Any) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            return
        }

        let activityVC = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(x: rootVC.view.bounds.midX,
                                        y: rootVC.view.bounds.midY,
                                        width: 0,
                                        height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootVC.present(activityVC, animated: true)
    }
    
    func loadURL(urlString: String){
        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func showProSheet(){
            NotificationCenter.default.post(name: NSNotification.proSheet, object: nil)
    }
    
    func showDeviceList(){
            NotificationCenter.default.post(name: NSNotification.deviceList, object: nil)
    }
    
    func dismissSheet(){
            NotificationCenter.default.post(name: NSNotification.dismissLGConnectView, object: nil)
    }
    
    func disconnectDevice(){
            NotificationCenter.default.post(name: NSNotification.dismissLGConnectView, object: nil)
    }
}

extension NSNotification {
    static var proSheet = Notification.Name.init("proSheet")
    static var deviceList = Notification.Name.init("deviceList")
    static let afterClickUpdated = Notification.Name.init("afterClickUpdated")
    static let dismissLGConnectView = Notification.Name.init("dismissLGConnectView")
    static let disconnectDevice = Notification.Name.init("disconnectDevice")
    static let airPlayPopupClosed = Notification.Name.init("airPlayPopupClosed")
    static let showLGPairingAlert = Notification.Name.init("showLGPairingAlert")
}
