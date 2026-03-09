//
//  NetworkManager.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import Alamofire
import UIKit

struct NetworkManager {
    
    static func cancelRequest(url: String) {
        AF.session.getAllTasks { tasks in
            let task = tasks.first(where: { $0.currentRequest?.url?.absoluteString == url })
            task?.cancel()
        }
    }
    
    static func cancelAllRequests() {
        AF.cancelAllRequests()
    }
    
    // MARK: - General Web Service Caller
    static func callWebService<T: Codable>(
        url: String,
        httpMethod: HTTPMethod = .get,
        params: [String: Any] = [:],
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders = [:], // Empty headers by default
        callbackSuccess: @escaping (T) -> (),
        callbackFailure: @escaping (_ err: Error) -> () = { _ in }
    ) {
        // Ensure URL has proper scheme
        var finalURL = url
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            finalURL = "https://" + url
        }
        
        print("==================================================================")
        print("Request URL:", finalURL)
        print("Method:", httpMethod.rawValue)
        print("Headers:", headers)
        print("Parameters:", params)
        
        AF.request(finalURL,
                   method: httpMethod,
                   parameters: params,
                   encoding: encoding,
                   headers: headers)
        .validate()
        .responseDecodable(of: T.self) { response in
            print("Time Duration in second:", response.metrics?.taskInterval.duration ?? 0)
            
            switch response.result {
            case .success(let value):
                print("✅ Successfully decoded response")
                callbackSuccess(value)
                
            case .failure(let error):
                print("❌ Network Error:", error)
                
                // Print response data for debugging
                if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw Response:", jsonString)
                }
                
                // Try to decode error message if available
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let message = json?["message"] as? String {
                            print("Error message:", message)
                        }
                    } catch {
                        print("Could not parse error response")
                    }
                }
                
                callbackFailure(error)
            }
        }
    }
    
    // MARK: - File Upload Web Service
    static func callWebServiceWithFiles<T: Codable>(
        url: String,
        params: [String: Any] = [:],
        headers: HTTPHeaders = [:],
        callbackSuccess: @escaping (T) -> (),
        callbackFailure: @escaping (_ err: Error) -> () = { _ in }
    ) {
        AF.upload(multipartFormData: { multipartFormData in
            params.forEach { (key, value) in
                if let urls = value as? [URL] {
                    urls.forEach { fileURL in
                        multipartFormData.append(fileURL,
                                                 withName: key,
                                                 fileName: "file.\(fileURL.pathExtension)",
                                                 mimeType: mimeType(for: fileURL.pathExtension))
                    }
                } else if let images = value as? [UIImage] {
                    images.forEach { image in
                        if let data = image.jpegData(compressionQuality: 1.0) {
                            multipartFormData.append(data,
                                                     withName: key,
                                                     fileName: "image.jpg",
                                                     mimeType: "image/jpeg")
                        }
                    }
                } else {
                    if let data = "\(value)".data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
            }
        }, to: url, headers: headers)
        .uploadProgress { progress in
            print("Upload Progress:", progress.fractionCompleted)
        }
        .responseDecodable(of: T.self) { response in
            print("==================================================================")
            print("Request URL:", response.request?.url?.absoluteString ?? "")
            print("Headers:", headers)
            print("Parameters:", params)
            print("Time Duration in second:", response.metrics?.taskInterval.duration ?? 0)
            
            switch response.result {
            case .success(let value):
                callbackSuccess(value)
            case .failure(let error):
                callbackFailure(error)
            }
        }
    }
    
    // Helper: MIME type resolver
    private static func mimeType(for pathExtension: String) -> String {
        switch pathExtension.lowercased() {
        case "jpg", "jpeg": return "image/jpeg"
        case "png": return "image/png"
        case "mp4": return "video/mp4"
        case "mov": return "video/quicktime"
        default: return "application/octet-stream"
        }
    }
}
