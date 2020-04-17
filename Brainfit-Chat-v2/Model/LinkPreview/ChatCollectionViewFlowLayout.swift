//
//  ChatCollectionViewFlowLayout.swift
//  Engage
//
//  Created by Bruno Guidolim on 04.08.19.
//  Copyright © 2019 COYO GmbH. All rights reserved.
//

import MessageKit

internal final class ChatCollectionViewFlowLayout: MessagesCollectionViewFlowLayout {

    lazy var systemMessageCalculator: ChatSystemMessageCalculator = .init(layout: self)
    lazy var linkMessageCalculator: LinkMessageSizeCalculator = .init(layout: self)

    override init() {
        super.init()

        setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 30))
        setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 8))

        setMessageOutgoingAvatarSize(.zero)
        textMessageSizeCalculator.messageLabelFont = UIFont.bodyFont
        linkMessageCalculator.messageLabelFont = UIFont.bodyFont

        let labelInsets: UIEdgeInsets = .init(top: 7, left: 12, bottom: 7, right: 12)
        textMessageSizeCalculator.incomingMessageLabelInsets = labelInsets
        textMessageSizeCalculator.outgoingMessageLabelInsets = labelInsets
        linkMessageCalculator.incomingMessageLabelInsets = labelInsets
        linkMessageCalculator.outgoingMessageLabelInsets = labelInsets

        setMessageIncomingAvatarPosition(.init(vertical: .messageBottom))

        let outgoingBottomLabelAlignment: LabelAlignment = .init(textAlignment: .right,
                                                                 textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 19))
        setMessageOutgoingMessageBottomLabelAlignment(outgoingBottomLabelAlignment)

        let incomingLabelAlignment: LabelAlignment = .init(textAlignment: .left,
                                                           textInsets: UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0))
        setMessageIncomingMessageBottomLabelAlignment(incomingLabelAlignment)
        setMessageIncomingMessageTopLabelAlignment(incomingLabelAlignment)

        minimumLineSpacing = 2
        sectionInset = UIEdgeInsets(top: 1, left: 16, bottom: 1, right: 16)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func messageSizeCalculators() -> [MessageSizeCalculator] {
        return super.messageSizeCalculators() + [systemMessageCalculator, linkMessageCalculator]
    }
}
