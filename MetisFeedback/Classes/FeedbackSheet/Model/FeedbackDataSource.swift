//
//  FeedbackDataSource.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/7/22.
//

import Foundation
import MetisLego

public struct FeedbackDataSource: Codable {
    struct Tag: Codable {
        var id: Int
        var name: String
    }

    typealias ExtraType = [String: String]

    @DefaultCoding<EmptyArray>
    var tags: [Tag]
    var biz: String
    var bizId: String
    var extra: ExtraType?
}
