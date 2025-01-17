//
//  PlistHelper.swift
//  
//
//  Created by David Frontegg on 22/12/2022.
//

import Foundation


public enum FronteggError: Error {
    case configError(String)
    case authError(String)
}

struct PlistHelper {
    
    private static var logLevelCache: Logger.Level? = nil
    
    public static func fronteggConfig() throws -> (clientId: String, baseUrl: String, keychainService: String, bundleIdentifier: String) {
        let bundle = Bundle.main;
        
        let resourceName = (getenv("frontegg-testing") != nil) ? "FronteggTest" : "Frontegg"
            
        guard let path = bundle.path(forResource: resourceName, ofType: "plist"),
              let values = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            let errorMessage = "Missing Frontegg.plist file with 'clientId' and 'baseUrl' entries in main bundle!"
            print(errorMessage)
            throw FronteggError.configError(errorMessage)
        }
        
        guard let clientId = values["clientId"] as? String, let baseUrl = values["baseUrl"] as? String else {
            let errorMessage = "Frontegg.plist file at \(path) is missing 'clientId' and/or 'baseUrl' entries!"
            print(errorMessage)
            throw FronteggError.configError(errorMessage)
        }
        
        let keychainService = values["keychainService"] as? String ?? "frontegg"
        
        return (clientId: clientId, baseUrl: baseUrl, keychainService: keychainService, bundleIdentifier: bundle.bundleIdentifier!)
    }
    
    public static func getLogLevel() -> Logger.Level {
        
        if let logLevel = PlistHelper.logLevelCache {
            return logLevel
        }
        
        let map = [
            "trace": 0,
            "debug": 1,
            "info": 2,
            "warn": 3,
            "error": 4,
            "critical": 5
        ]
        
        let bundle = Bundle.main;
        if let path = bundle.path(forResource: "Frontegg", ofType: "plist"),
           let values = NSDictionary(contentsOfFile: path) as? [String: Any],
           let logLevelStr = values["logLevel"] as? String,
           let logLevelNum = map[logLevelStr],
           let logLevel = Logger.Level.init(rawValue: logLevelNum) {
            
            return logLevel
        }
        
        return Logger.Level.warning
    }
    
    public static func isEmbeddedMode() -> Bool {
        
        let bundle = Bundle.main;
        if let path = bundle.path(forResource: "Frontegg", ofType: "plist"),
           let values = NSDictionary(contentsOfFile: path) as? [String: Any],
           let embeddedMode =  values["embeddedMode"] as? Bool {
            
            return embeddedMode
        }
        
        return true
    }
}

