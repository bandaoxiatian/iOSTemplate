//
//  FeedbackUtils.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/8/11.
//

import Foundation

struct FeedbackUtils {

    static let bundleName = "MetisFeedback"

}

extension UIImage {
    convenience init?(libraryImageNamed imageName: String) {
        guard let bundlePath = Bundle.main.path(forResource: FeedbackUtils.bundleName, ofType: "bundle") else {
            return nil
        }
        guard let imageBundle = Bundle(path: bundlePath) else {
            return nil
        }
        self.init(named: imageName, in: imageBundle, compatibleWith: nil)
    }
}
