//
//  MSWError.swift
//  MSW Surf Lodge Search
//
//  Created by Tom Bastable on 29/02/2020.
//  Copyright © 2020 Tom Bastable. All rights reserved.
//

import Foundation

enum LocationError: Error{
    
    //general errors
    case coordinateError
    case fillOutAllFields
    case locationPermissionsError
    case userCancelledInput
    //networking errors
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    //result errors
    case jsonParsingFailure
    case noResults
    
}

//extend LocationError to support LocalizedError, so that it's easier to display errors in AlertControllers.
extension LocationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .coordinateError:
            return NSLocalizedString("Coordinates are Invalid.", comment: "Error")
        case .noResults:
            return NSLocalizedString("No Lodges Found Within 1km Of That Area", comment: "Error")
        case .requestFailed:
            return NSLocalizedString("Request Failed - Please check your network connection.", comment: "Error")
        case .jsonConversionFailure:
            return NSLocalizedString("Invalid Response From Server", comment: "Error")
        case .invalidData:
            return NSLocalizedString("Server Response Unexpected", comment: "Error")
        case .responseUnsuccessful:
            return NSLocalizedString("Request Failed - Please check your network connection.", comment: "Error")
        case .jsonParsingFailure:
            return NSLocalizedString("Request Failed - Please check your network connection.", comment: "Error")
        case .fillOutAllFields:
            return NSLocalizedString("Please ensure you type in valid location coordinate", comment: "Error")
        case .userCancelledInput:
            return NSLocalizedString("Input Cancelled", comment: "")
        case .locationPermissionsError:
            return NSLocalizedString("You will need to grant this app permission to use your location and provide notifications for it to work as designed. You can change this setting in the settings app on your device.", comment: "")
    }
}
}
