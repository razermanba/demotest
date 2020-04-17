//
//  LinkMessageSizeCalculator.swift
//  Engage
//
//Users/macbook/Documents/swift-branfit-chat/Brainfit-Chat-v2/Model/LinkPreview/ChatCollectionViewFlowLayout.swift//  Created by Bruno Guidolim on 04.08.19.
//  Copyright © 2019 COYO GmbH. All rights reserved.
//

import UIKit
import MessageKit


internal final class LinkMessageSizeCalculator: TextMessageSizeCalculator {

    private typealias Message = (message: String, linkURL: URL, linkPreview: ChatLinkPreview?)

    static let ImageViewSize: CGFloat = 60
    static let ImageViewMargin: CGFloat = 8

    private var chatLinkPreview: ChatLinkPreview?

    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        return chatLinkPreview == nil ?
            super.messageContainerMaxWidth(for: message) :
            (layout?.collectionView?.bounds.width ?? 0.0) * 0.75
    }

    override func messageContainerSize(for message: MessageType) -> CGSize {
        let messageTuple: Message = unwrapMessage(message)
        self.chatLinkPreview = messageTuple.linkPreview

        guard let chatMessage = message as? ChatMessage else { return .zero }
        let dummyMessage: ChatMessage = .init(sender: message.sender,
                                              messageId: message.messageId,
                                              sentDate: message.sentDate,
                                              kind: .text(messageTuple.message),
                                              updatedID: chatMessage.updatedID)

        var containerSize: CGSize = super.messageContainerSize(for: dummyMessage)

        guard let linkPreview = chatLinkPreview, !linkPreview.teaser.isEmptyOrNil else {
            return containerSize
        }

        let labelInsets: UIEdgeInsets = messageLabelInsets(for: message)
        let maxWidth: CGFloat = messageContainerMaxWidth(for: message)

        containerSize.width = max(containerSize.width, maxWidth)

        let minHeight: CGFloat = containerSize.height + LinkMessageSizeCalculator.ImageViewSize
        let previewMaxWidth: CGFloat = containerSize.width - (LinkMessageSizeCalculator.ImageViewSize + LinkMessageSizeCalculator.ImageViewMargin + labelInsets.horizontal)

        calculateContainerSize(with: NSAttributedString(string: linkPreview.title ?? "", attributes: [.font: UIFont.caption1SemiBoldFont]),
                               containerSize: &containerSize,
                               maxWidth: previewMaxWidth)

        calculateContainerSize(with: NSAttributedString(string: linkPreview.teaser ?? "", attributes: [.font: UIFont.caption2Font]),
                               containerSize: &containerSize,
                               maxWidth: previewMaxWidth)

        calculateContainerSize(with: NSAttributedString(string: linkPreview.domain ?? "", attributes: [.font: UIFont.caption2SemiBoldFont]),
                               containerSize: &containerSize,
                               maxWidth: previewMaxWidth)

//        containerSize.height = max(minHeight, containerSize.height) + labelInsets.vertical

        return containerSize
    }

    private func calculateContainerSize(with attibutedString: NSAttributedString, containerSize: inout CGSize, maxWidth: CGFloat) {
        if attibutedString.string.isEmpty {
            return
        }
//        let size: CGSize = attibutedString.labelSize(considering: maxWidth)
        containerSize.height += size.height
    }

    private func messageLabelInsets(for message: MessageType) -> UIEdgeInsets {
        let dataSource: MessagesDataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender: Bool = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageLabelInsets : incomingMessageLabelInsets
    }

    private func unwrapMessage(_ message: MessageType) -> Message {
        guard case .custom(let object) = message.kind,
//            let customType = object as? ChatMessageCustomType,
            case let .link(attributes) = customType else {
                preconditionFailure("Was not possible to unwrap the custom type.")
        }
        return (attributes.message, attributes.linkURL, attributes.linkPreview)
    }
}
