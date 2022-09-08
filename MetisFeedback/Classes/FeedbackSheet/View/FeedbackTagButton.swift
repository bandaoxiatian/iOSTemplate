//
//  FeedbackTagButton.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/7/25.
//

import UIKit
import RxSwift
import RxCocoa

final class FeedbackTagButton: UIButton {

    let datasourceTag: FeedbackDataSource.Tag

    override var isSelected: Bool {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    init(tag: FeedbackDataSource.Tag) {
        datasourceTag = tag
        super.init(frame: .zero)
        createUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createUI() {
        setTitle(datasourceTag.name, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 14)

        layer.cornerRadius = 6
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if isSelected {
            setTitleColor(.tintNormal, for: .selected)
            backgroundColor = .grayBackgroundHover
        } else {
            setTitleColor(.colorTitle, for: .normal)
            backgroundColor = UIColor(hex: 0xEEEEEE, alpha: 0.7)
        }
    }

}
