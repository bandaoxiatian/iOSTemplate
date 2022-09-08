//
//  FeedbackActionSheet.swift
//  MetisMessage
//
//  Created by Lyon on 2022/7/22.
//

import UIKit
import RxSwift
import MetisUI
import MetisLego
import VGOPresenter

public final class FeedbackActionSheet: UIView {

    public typealias TriggerHandler = (ErrorCode) -> Void

    private let sheetWidth: CGFloat
    private let dataSource: FeedbackDataSource

    private let viewModel: FeedbackSheetViewModel
    private let bag = DisposeBag()

    private let handler: TriggerHandler?

    private static let commentLimitCount = 40

    private var contentView = UIView().then {
        $0.backgroundColor = .fillLightGray
        $0.layer.cornerRadius = 14
    }

    private lazy var topBar: UIView = {
        let view = UIView()

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .colorTitle
        label.text = "有以下问题需要改进"
        view.addSubview(label)

        let button = UIButton()
        button.setImage(UIImage(libraryImageNamed: "feedback_sheet_close"), for: .normal)

        button.rx.tap.subscribeNext { [weak self] _ in
            self?.cancelFeedback()
            Presenter.dismiss()
        }
        view.addSubview(button)

        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 52, height: 52))
            make.centerY.equalTo(label)
            make.right.equalToSuperview()
        }

        return view
    }()

    private lazy var tagContainerView: FeedbackTagContainerView = {
        let view = FeedbackTagContainerView(tags: dataSource.tags)
        return view
    }()

    private var textView = PlaceholderTextView().then {
        $0.backgroundColor = UIColor(hex: 0xFFFFFF)
        $0.tintColor = .tintNormal
        $0.textColor = .colorTitle
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.keyboardDismissMode = .onDrag
        $0.returnKeyType = .continue
        $0.layer.cornerRadius = 6
        $0.layer.masksToBounds = true
        $0.placeholder = "其他建议或感受，40字以内（选填）"
        $0.placeholderColor = UIColor(hex: 0x9C9C9C)
    }

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .subNormal
        button.setTitle("确认提交", for: .normal)
        button.layer.cornerRadius = confirmButtonHeight / 2
        return button
    }()

    public init(width: CGFloat = FeedbackActionSheet.sheetWidth, dataSource: FeedbackDataSource, handler: TriggerHandler?) {
        self.sheetWidth = width
        self.dataSource = dataSource
        self.handler = handler
        self.viewModel = FeedbackSheetViewModel(dataSource: dataSource)
        super.init(frame: .zero)
        createUI()
        bindEvent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createUI() {
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.width.equalTo(self.sheetWidth)
            make.height.greaterThanOrEqualTo(sheetMinHeight)
        }

        contentView.addSubview(topBar)
        topBar.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(topBarHeight)
        }

        contentView.addSubview(tagContainerView)
        tagContainerView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp_bottom).offset(stackMarginTopBar)
            make.left.right.equalToSuperview()
        }

        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Self.stackMarginLeft)
            make.right.equalToSuperview().offset(-Self.stackMarginLeft)
            make.top.equalTo(tagContainerView.snp_bottom).offset(textViewMarginTags)
            make.height.greaterThanOrEqualTo(textViewMinHeight)
        }

        contentView.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Self.stackMarginLeft)
            make.right.equalToSuperview().offset(-Self.stackMarginLeft)
            make.top.equalTo(textView.snp_bottom).offset(confirmBtnMarginTextView)
            make.height.equalTo(confirmButtonHeight)
            make.bottom.equalToSuperview().offset(-confirmButtonMarginBottom)
        }
    }

    private func bindEvent() {
        contentView.rx.tapGesture().subscribeNext { [weak self] _ in
            self?.textView.resignFirstResponder()
        }.disposed(by: bag)

        tagContainerView.eventPublisher.subscribeNext { [weak self] item in
            guard let self = self, let tag = item.tag else { return }

            if item.isSelected {
                self.viewModel.selectedTags.append(tag)
            } else {
                self.viewModel.selectedTags.removeAll(where: { $0.id == tag.id })
            }
        }.disposed(by: bag)

        textView.rx.text.orEmpty.changed.subscribeNext { [weak self] text in
            self?.viewModel.comment = text
        }.disposed(by: bag)

        confirmButton.rx.tap.subscribeNext { [weak self] in
            guard let self = self else { return }

            self.commit()
        }.disposed(by: bag)
    }

    private func commit() {
        let comment = self.viewModel.comment.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard !(comment.isEmpty && self.viewModel.selectedTags.isEmpty) else {
            MetisViewControllerUtils.currentTopController()?.view.showToast("还没有反馈哦", position: .center)
            return
        }
        guard comment.count <= Self.commentLimitCount else {
            MetisViewControllerUtils.currentTopController()?.view.showToast("评论字数过长哦", position: .center)
            return
        }

        let topVC = MetisViewControllerUtils.currentTopController()
        topVC?.view.showLoading("", .center)
        self.viewModel.commitFeedback { [weak self] in
            guard let self = self else { return }
            topVC?.view.hideLoading()
            topVC?.view.showToast("感谢你的反馈", position: .center)
            self.viewModel.failedFlag = false
            self.handler?(.success)
            Presenter.dismiss()
        } failure: { [weak self] error in
            guard let self = self else { return }
            topVC?.view.hideLoading()
            topVC?.view.showToast(error?.localizedDescription ?? "反馈提交失败", position: .center)
            self.viewModel.failedFlag = true
        }
    }

    public func show() {
        var attr = PresenterAttributes()
        attr.screenInteraction = .customAction(with: { [weak self] in
            // click background
            self?.cancelFeedback()
            Presenter.dismiss()
        })
        attr.position = .bottom
        attr.container = .viewController
        attr.positionConstraints.rotation.isEnabled = false
        attr.entranceAnimation = .translation
        attr.exitAnimation = .translation
        let offset = confirmBtnMarginTextView + confirmButtonHeight + confirmButtonMarginBottom - 20
        attr.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: -offset))
        Presenter.show(self, using: attr)
    }

    private func cancelFeedback() {
        self.handler?(self.viewModel.failedFlag ? .failToCancel : .cancel)
    }
}

extension FeedbackActionSheet {

    private var sheetMinHeight: CGFloat { return 382 }

    private var topBarHeight: CGFloat { return 66 }

    private var stackMarginTopBar: CGFloat { return 8 }

    public static var stackMarginLeft: CGFloat { return 18 }

    private var textViewMarginTags: CGFloat { return 16 }

    private var textViewMinHeight: CGFloat { return 100 }

    private var confirmBtnMarginTextView: CGFloat { return 24 }

    private var confirmButtonHeight: CGFloat { return 44 }

    private var confirmButtonMarginBottom: CGFloat { return LayoutConstants.extraBottomPadding + 16 }
}

public extension FeedbackActionSheet {
    public static let sheetWidth = LayoutConstants.screenWidth

    public static let sheetMaxHeight = LayoutConstants.screenHeight * 0.7
    public static let sheetMinHeight = LayoutConstants.screenHeight * 0.5
}

public extension FeedbackActionSheet {

    enum ErrorCode: Int, RawRepresentable {
        case failToCancel = -1  // 反馈失败后取消
        case success = 0        // 成功
        case cancel = 1         // 未提交取消
    }

}
