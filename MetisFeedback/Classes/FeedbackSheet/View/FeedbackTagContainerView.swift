//
//  FeedbackTagContainerView.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/7/25.
//

import UIKit
import RxSwift
import RxRelay
import MetisUI
import MetisLego

final class FeedbackTagContainerView: UIView {

    typealias SelectItem = (isSelected: Bool, tag: FeedbackDataSource.Tag?)

    private let eventSubject = PublishRelay<SelectItem>()
    public var eventPublisher: Observable<SelectItem> {
        eventSubject.asObservable()
    }

    private let tags: [FeedbackDataSource.Tag]

    init(tags: [FeedbackDataSource.Tag]) {
        self.tags = tags
        super.init(frame: .zero)
        createUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createUI() {
        var stackView: UIStackView?
        for (index, tag) in tags.enumerated() {
            let newRow = index % tagsPerRow == 0
            let row = index / tagsPerRow
            let maxRow = Int(ceil(Double(tags.count) / Double(tagsPerRow))) - 1
            let isFirstRow = row == 0
            let isLastRow = row == maxRow

            if newRow {
                stackView = UIStackView()
                stackView?.axis = .horizontal
                stackView?.alignment = .fill
                stackView?.distribution = .fillEqually
                stackView?.spacing = stackSpaceX

                addSubview(stackView!)

                stackView?.snp.makeConstraints({ make in
                    make.left.equalToSuperview().offset(Self.tagMarginLeft)
                    make.right.equalToSuperview().offset(-Self.tagMarginLeft)
                    make.top.equalToSuperview().offset((stackHeight + stackSpaceY) * CGFloat(row))
                    make.height.equalTo(stackHeight)
                    if isFirstRow {
                        make.top.equalToSuperview()
                    }
                    if isLastRow {
                        make.bottom.equalToSuperview()
                    }
                })
            }

            let button = FeedbackTagButton(tag: tag)
            stackView?.addArrangedSubview(button)

            button.rx.tap.subscribeNext { [weak self] in
                guard let self = self else { return }

                button.isSelected.toggle()
                self.eventSubject.accept(SelectItem(button.isSelected, button.datasourceTag))
            }

            // append placeholder button if odd tags
            let isLast = index == tags.count - 1
            if isLast && tags.count % 2 == 1 {
                let placeholder = UIButton()
                placeholder.alpha = 0
                placeholder.isUserInteractionEnabled = false
                stackView?.addArrangedSubview(placeholder)
            }
        }
    }
}

private extension FeedbackTagContainerView {
    private var tagsPerRow: Int {
        return 2
    }

    private var stackSpaceX: CGFloat {
        return 8
    }

    private var stackSpaceY: CGFloat {
        return 8
    }

    private var stackHeight: CGFloat {
        return 44
    }
}

extension FeedbackTagContainerView {

    static var tagMarginLeft: CGFloat {
        return 18
    }

}
