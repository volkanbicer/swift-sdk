//
//
//  Created by Tapash Majumder on 6/13/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

//import XCTest

import Foundation
import UserNotifications

@testable import IterableSDK

@available(iOS 10.0, *)
struct MockNotificationResponse : NotificationResponseProtocol {
    let userInfo: [AnyHashable : Any]
    let actionIdentifier: String
    
    init(userInfo: [AnyHashable : Any], actionIdentifier: String) {
        self.userInfo = userInfo;
        self.actionIdentifier = actionIdentifier
    }
    
    var textInputResponse: UNTextInputNotificationResponse? {
        return nil
    }
}


@objcMembers
public class MockUrlDelegate : NSObject, IterableURLDelegate {
    // returnValue = true if we handle the url, else false
    private override convenience init() {
        self.init(returnValue: false)
    }
    
    public init(returnValue: Bool) {
        self.returnValue = returnValue
    }
    
    private (set) var returnValue: Bool
    private (set) var url: URL?
    private (set) var context: IterableActionContext?
    var callback: ((URL, IterableActionContext)->Void)? = nil
    
    public func handle(iterableURL url: URL, inContext context: IterableActionContext) -> Bool {
        self.url = url
        self.context = context
        callback?(url, context)
        return returnValue
    }
}

@objcMembers
public class MockCustomActionDelegate: NSObject, IterableCustomActionDelegate {
    // returnValue is reserved for future, don't rely on this
    private override convenience init() {
        self.init(returnValue: false)
    }
    
    public init(returnValue: Bool) {
        self.returnValue = returnValue
    }
    
    private (set) var returnValue: Bool
    private (set) var action: IterableAction?
    private (set) var context: IterableActionContext?
    var callback: ((String, IterableActionContext)->Void)? = nil
    
    public func handle(iterableCustomAction action: IterableAction, inContext context: IterableActionContext) -> Bool {
        self.action = action
        self.context = context
        callback?(action.type, context)
        return returnValue
    }
}

@objc public class MockUrlOpener : NSObject, UrlOpenerProtocol {
    @objc var ios10OpenedUrl: URL?
    @objc var preIos10openedUrl: URL?
    
    public func open(url: URL) {
        if #available(iOS 10.0, *) {
            ios10OpenedUrl = url
        } else {
            preIos10openedUrl = url
        }
    }
}

@objcMembers
public class MockPushTracker : NSObject, PushTrackerProtocol {
    var campaignId: NSNumber?
    var templateId: NSNumber?
    var messageId: String?
    var appAlreadyRunnnig: Bool = false
    var dataFields: [AnyHashable : Any]?
    var onSuccess: OnSuccessHandler?
    var onFailure: OnFailureHandler?
    public var lastPushPayload: [AnyHashable : Any]?
    
    public func trackPushOpen(_ userInfo: [AnyHashable : Any]) {
        trackPushOpen(userInfo, dataFields: nil)
    }
    
    public func trackPushOpen(_ userInfo: [AnyHashable : Any], dataFields: [AnyHashable : Any]?) {
        trackPushOpen(userInfo, dataFields: dataFields, onSuccess: nil, onFailure: nil)
    }
    
    public func trackPushOpen(_ userInfo: [AnyHashable : Any], dataFields: [AnyHashable : Any]?, onSuccess: OnSuccessHandler?, onFailure: OnFailureHandler?) {
        // save payload
        lastPushPayload = userInfo
        
        if let metadata = IterableNotificationMetadata.metadata(fromLaunchOptions: userInfo), metadata.isRealCampaignNotification() {
            trackPushOpen(metadata.campaignId, templateId: metadata.templateId, messageId: metadata.messageId, appAlreadyRunning: false, dataFields: dataFields, onSuccess: onSuccess, onFailure: onFailure)
        } else {
            onFailure?("Not tracking push open - payload is not an Iterable notification, or a test/proof/ghost push", nil)
        }
    }
    
    public func trackPushOpen(_ campaignId: NSNumber, templateId: NSNumber?, messageId: String?, appAlreadyRunning: Bool, dataFields: [AnyHashable : Any]?) {
        trackPushOpen(campaignId, templateId: templateId, messageId: messageId, appAlreadyRunning: appAlreadyRunning, dataFields: dataFields, onSuccess: nil, onFailure: nil)
    }
    
    public func trackPushOpen(_ campaignId: NSNumber, templateId: NSNumber?, messageId: String?, appAlreadyRunning: Bool, dataFields: [AnyHashable : Any]?, onSuccess: OnSuccessHandler?, onFailure: OnFailureHandler?) {
        self.campaignId = campaignId
        self.templateId = templateId
        self.messageId = messageId
        self.appAlreadyRunnnig = appAlreadyRunning
        self.dataFields = dataFields
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
}

@objc public class MockApplicationStateProvider : NSObject, ApplicationStateProviderProtocol {
    private override convenience init() {
        self.init(applicationState: .active)
    }
    
    @objc public init(applicationState: UIApplication.State) {
        self.applicationState = applicationState
    }
    
    public var applicationState: UIApplication.State
}

class MockNetworkSession: NetworkSessionProtocol {
    var request: URLRequest?
    var callback: ((Data?, URLResponse?, Error?) -> Void)?
    
    var statusCode: Int
    var data: Data?
    var error: Error?
    
    convenience init(statusCode: Int) {
        self.init(statusCode: statusCode,
                  data: [:].toData(),
                  error: nil)
    }
    
    convenience init(statusCode: Int, json: [AnyHashable : Any], error: Error? = nil) {
        self.init(statusCode: statusCode,
                  data: json.toData(),
                  error: error)
    }
    
    init(statusCode: Int, data: Data?, error: Error? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.error = error
    }
    
    func makeRequest(_ request: URLRequest, completionHandler: @escaping NetworkSessionProtocol.CompletionHandler) {
        DispatchQueue.main.async {
            self.request = request
            let response = HTTPURLResponse(url: request.url!, statusCode: self.statusCode, httpVersion: "HTTP/1.1", headerFields: [:])
            completionHandler(self.data, response, self.error)
            
            self.callback?(self.data, response, self.error)
        }
    }
    
    func getRequestBody() -> [AnyHashable : Any] {
        return MockNetworkSession.json(fromData: request!.httpBody!)
    }
    
    static func json(fromData data: Data) -> [AnyHashable : Any] {
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable : Any]
    }
}

class NoNetworkNetworkSession: NetworkSessionProtocol {
    func makeRequest(_ request: URLRequest, completionHandler: @escaping NetworkSessionProtocol.CompletionHandler) {
        DispatchQueue.main.async {
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [:])
            let error = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
            completionHandler(try! JSONSerialization.data(withJSONObject: [:], options: []), response, error)
        }
    }
}

