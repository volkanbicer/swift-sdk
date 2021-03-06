//
//  IterableInAppNotificationTests.swift
//  swift-sdk-swift-tests

//  Created by David Truong on 10/3/17.
//  Migrated to Swift by Tapash Majumder on 7/10/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

import XCTest

@testable import IterableSDK

class IterableInAppNotificationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetNextNotificationNil() {
        let message = IterableInAppManager.getNextMessageFromPayload(nil)
        XCTAssertNil(message)
    }
    
    func testGetNextNotificationEmpty() {
        let message = IterableInAppManager.getNextMessageFromPayload([:])
        XCTAssertNil(message)
    }
    
    func testNotificationCreation() {
        //call showIterableNotificationHTML with fake data
        //Check the top level dialog
        
        let htmlString = "<a href=\"http://www.iterable.com\" target=\"http://www.iterable.com\">test</a>"
        let baseNotification = IterableInAppHTMLViewController(data: htmlString)
        let html = baseNotification.getHtml()
        XCTAssertEqual(html, htmlString)
    }
    
    func testGetPaddingInvalid() {
        let insets = IterableInAppManager.getPaddingFromPayload([:])
        XCTAssertEqual(insets, UIEdgeInsets.zero)
    }
    
    func testGetPaddingFull() {
        let payload: [AnyHashable : Any] = [
            "top" : ["percentage" : "0"],
            "left" : ["percentage" : "0"],
            "bottom" : ["percentage" : "0"],
            "right" : ["right" : "0"],
        ]
        
        let insets = IterableInAppManager.getPaddingFromPayload(payload)
        XCTAssertEqual(insets, UIEdgeInsets.zero)
        
        var padding = UIEdgeInsets.zero
        padding.top = CGFloat(IterableInAppManager.decodePadding(payload["top"]))
        padding.left = CGFloat(IterableInAppManager.decodePadding(payload["left"]))
        padding.bottom = CGFloat(IterableInAppManager.decodePadding(payload["bottom"]))
        padding.right = CGFloat(IterableInAppManager.decodePadding(payload["right"]))
        XCTAssertEqual(padding, UIEdgeInsets.zero)
    }
    
    func testGetPaddingCenter() {
        let payload: [AnyHashable : Any] = [
            "top" : ["displayOption" : "AutoExpand"],
            "left" : ["percentage" : "0"],
            "bottom" : ["displayOption" : "AutoExpand"],
            "right" : ["right" : "0"],
            ]
        
        let insets = IterableInAppManager.getPaddingFromPayload(payload)
        XCTAssertEqual(insets, UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0))
        
        var padding = UIEdgeInsets.zero
        padding.top = CGFloat(IterableInAppManager.decodePadding(payload["top"]))
        padding.left = CGFloat(IterableInAppManager.decodePadding(payload["left"]))
        padding.bottom = CGFloat(IterableInAppManager.decodePadding(payload["bottom"]))
        padding.right = CGFloat(IterableInAppManager.decodePadding(payload["right"]))
        XCTAssertEqual(padding, UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0))
    }
    
    func testGetPaddingTop() {
        let payload: [AnyHashable : Any] = [
            "top" : ["percentage" : "0"],
            "left" : ["percentage" : "0"],
            "bottom" : ["displayOption" : "AutoExpand"],
            "right" : ["right" : "0"],
            ]
        
        let insets = IterableInAppManager.getPaddingFromPayload(payload)
        XCTAssertEqual(insets, UIEdgeInsets(top: 0, left: 0, bottom: -1, right: 0))
        
        var padding = UIEdgeInsets.zero
        padding.top = CGFloat(IterableInAppManager.decodePadding(payload["top"]))
        padding.left = CGFloat(IterableInAppManager.decodePadding(payload["left"]))
        padding.bottom = CGFloat(IterableInAppManager.decodePadding(payload["bottom"]))
        padding.right = CGFloat(IterableInAppManager.decodePadding(payload["right"]))
        XCTAssertEqual(padding, UIEdgeInsets(top: 0, left: 0, bottom: -1, right: 0))
    }
    
    func testGetPaddingBottom() {
        let payload: [AnyHashable : Any] = [
            "top" : ["displayOption" : "AutoExpand"],
            "left" : ["percentage" : "0"],
            "bottom" : ["percentage" : "0"],
            "right" : ["right" : "0"],
            ]
        
        let insets = IterableInAppManager.getPaddingFromPayload(payload)
        XCTAssertEqual(insets, UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0))
        
        var padding = UIEdgeInsets.zero
        padding.top = CGFloat(IterableInAppManager.decodePadding(payload["top"]))
        padding.left = CGFloat(IterableInAppManager.decodePadding(payload["left"]))
        padding.bottom = CGFloat(IterableInAppManager.decodePadding(payload["bottom"]))
        padding.right = CGFloat(IterableInAppManager.decodePadding(payload["right"]))
        XCTAssertEqual(padding, UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0))
    }
    
    func testNotificationPaddingFull() {
        let notificationType = IterableInAppHTMLViewController.setLocation(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        XCTAssertEqual(notificationType, .full)
    }

    func testNotificationPaddingTop() {
        let notificationType = IterableInAppHTMLViewController.setLocation(UIEdgeInsets(top: 0, left: 0, bottom: -1, right: 0))
        XCTAssertEqual(notificationType, .top)
    }
    
    func testNotificationPaddingBottom() {
        let notificationType = IterableInAppHTMLViewController.setLocation(UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0))
        XCTAssertEqual(notificationType, .bottom)
    }

    func testNotificationPaddingCenter() {
        let notificationType = IterableInAppHTMLViewController.setLocation(UIEdgeInsets(top: -1, left: 0, bottom: -1, right: 0))
        XCTAssertEqual(notificationType, .center)
    }

    func testNotificationPaddingDefault() {
        let notificationType = IterableInAppHTMLViewController.setLocation(UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0))
        XCTAssertEqual(notificationType, .center)
    }
    
    func testDoNotShowMultipleTimes() {
        let shownFirstTime = IterableInAppManager.showIterableNotificationHTML("", callbackBlock: nil)
        let shownSecondTime = IterableInAppManager.showIterableNotificationHTML("", callbackBlock: nil)
        XCTAssertTrue(shownFirstTime)
        XCTAssertFalse(shownSecondTime)
    }
    
    func testGetBackgroundAlpha() {
        XCTAssert(IterableInAppManager.getBackgroundAlpha(fromInAppSettings: nil) == 0)
        XCTAssert(IterableInAppManager.getBackgroundAlpha(fromInAppSettings: ["backgroundAlpha" : "x"]) == 0)
        XCTAssert(IterableInAppManager.getBackgroundAlpha(fromInAppSettings: ["backgroundAlpha" : 0.5]) == 0.5)
        XCTAssert(IterableInAppManager.getBackgroundAlpha(fromInAppSettings: ["backgroundAlpha" : 1]) == 1.0)
    }
    
    func testTrackInAppClickWithButtonUrl() {
        let messageId = "message1"
        let buttonUrl = "http://somewhere.com"
        let expectation1 = expectation(description: "track in app click")

        let networkSession = MockNetworkSession(statusCode: 200)
        IterableAPI.initialize(apiKey: IterableInAppNotificationTests.apiKey, networkSession: networkSession)
        IterableAPI.userId = IterableInAppNotificationTests.userId
        networkSession.callback = {(_, _, _) in
            TestUtils.validate(request: networkSession.request!,
                               requestType: .post,
                               apiEndPoint: .ITBL_ENDPOINT_API,
                               path: .ITBL_PATH_TRACK_INAPP_CLICK,
                               queryParams: [(name: AnyHashable.ITBL_KEY_API_KEY, value: IterableInAppNotificationTests.apiKey),
                ])
            let body = networkSession.getRequestBody() as! [String : Any]
            TestUtils.validateMatch(keyPath: KeyPath("messageId"), value: messageId, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath("clickedUrl"), value: buttonUrl, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath("userId"), value: IterableInAppNotificationTests.userId, inDictionary: body)
            expectation1.fulfill()
        }
        IterableAPI.track(inAppClick: messageId, buttonURL: buttonUrl)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }

    func testTrackInAppClickWithButtonIndex() {
        let messageId = "message1"
        let buttonIndex = "1"
        let expectation1 = expectation(description: "track in app click")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        IterableAPI.initialize(apiKey: IterableInAppNotificationTests.apiKey, networkSession: networkSession)
        IterableAPI.email = IterableInAppNotificationTests.email
        networkSession.callback = {(_, _, _) in
            TestUtils.validate(request: networkSession.request!,
                               requestType: .post,
                               apiEndPoint: .ITBL_ENDPOINT_API,
                               path: .ITBL_PATH_TRACK_INAPP_CLICK,
                               queryParams: [(name: AnyHashable.ITBL_KEY_API_KEY, value: IterableInAppNotificationTests.apiKey),
                                             ])
            let body = networkSession.getRequestBody() as! [String : Any]
            TestUtils.validateMatch(keyPath: KeyPath("messageId"), value: messageId, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath("buttonIndex"), value: buttonIndex, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath("email"), value: IterableInAppNotificationTests.email, inDictionary: body)
            expectation1.fulfill()
        }
        IterableAPI.track(inAppClick: messageId, buttonIndex: buttonIndex)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }

    func testTrackInAppOpen() {
        let messageId = "message1"
        let expectation1 = expectation(description: "track in app open")
        
        let networkSession = MockNetworkSession(statusCode: 200)
        IterableAPI.initialize(apiKey: IterableInAppNotificationTests.apiKey, networkSession: networkSession)
        IterableAPI.email = IterableInAppNotificationTests.email
        networkSession.callback = {(_, _, _) in
            TestUtils.validate(request: networkSession.request!,
                               requestType: .post,
                               apiEndPoint: .ITBL_ENDPOINT_API,
                               path: .ITBL_PATH_TRACK_INAPP_OPEN,
                               queryParams: [(name: AnyHashable.ITBL_KEY_API_KEY, value: IterableInAppNotificationTests.apiKey),
                                             ])
            let body = networkSession.getRequestBody() as! [String : Any]
            TestUtils.validateMatch(keyPath: KeyPath(AnyHashable.ITBL_KEY_MESSAGE_ID), value: messageId, inDictionary: body)
            TestUtils.validateMatch(keyPath: KeyPath(AnyHashable.ITBL_KEY_EMAIL), value: IterableInAppNotificationTests.email, inDictionary: body)
            expectation1.fulfill()
        }
        IterableAPI.track(inAppOpen: messageId)
        wait(for: [expectation1], timeout: testExpectationTimeout)
    }

    private static let apiKey = "zeeApiKey"
    private static let email = "user@example.com"
    private static let userId = "userId1"
}
