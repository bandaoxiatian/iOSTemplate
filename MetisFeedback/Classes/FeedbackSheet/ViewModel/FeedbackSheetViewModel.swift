//
//  FeedbackSheetViewModel.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/7/22.
//

import Foundation
import RxSwift
import MetisLego
import MetisAccount
import Alamofire

final class FeedbackSheetViewModel {
    let dataSource: FeedbackDataSource

    var comment: String = ""
    var selectedTags: [FeedbackDataSource.Tag] = []

    private var requestBag = DisposeBag()

    var failedFlag = false

    typealias SuccessHandler = () -> Void
    typealias FailureHandler = (Error?) -> Void

    init(dataSource: FeedbackDataSource) {
        self.dataSource = dataSource
    }

    func commitFeedback(success: SuccessHandler? = nil, failure: FailureHandler? = nil) {
        requestBag = DisposeBag()

        let path = "/metis-studium-feedback/{client}/report/" + dataSource.biz
        let url = MetisURL(path: path)
        var params: [String: Any] = [
            "bizId": dataSource.bizId,
            "content": comment,
            "tagIds": selectedTags.map { $0.id }
        ]
        if let extra = dataSource.extra {
            params.updateValue(extra, forKey: "extra")
        }

        AF
            .metisRequest(
                url,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default
            )
            .validate(statusCode: 0 ..< 50000)
            .responseDecodable(of: [String: MetisAnyDecodable].self, completionHandler: { response in
                switch response.result {
                case .success(let dict):
                    guard let code = dict["code"]?.value as? String, code == "0" else {
                        failure?(response.error)
                        return
                    }
                    success?()
                case .failure(let error):
                    failure?(error)
                }
            })
    }
}
