//
//  LinkMessageCell.swift
//  Engage
//
//  Created by Bruno Guidolim on 04.08.19.
//  Copyright © 2019 COYO GmbH. All rights reserved.
//

import MessageKit

internal final class LinkMessageCell: TextMessageCell {
    private let linkPreviewView: LinkPreviewView = .init()
    private var linkURL: URL?

    override func configure(with message: MessageType,
                            at indexPath: IndexPath,
                            and messagesCollectionView: MessagesCollectionView) {
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }

        let textColor: UIColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        linkPreviewView.titleLabel.textColor = textColor
        linkPreviewView.teaserLabel.textColor = textColor
        linkPreviewView.domainLabel.textColor = textColor

        guard case .custom(let object) = message.kind,
            let customType = object as? ChatMessageCustomType,
            let chatMessage = message as? ChatMessage else {
                preconditionFailure("Was not possible to unwrap the custom type.")
        }

        switch customType {
        case .link(let messageText, let linkURL, let linkPreview):
            let newChatMessage: ChatMessage = .init(sender: chatMessage.sender,
                                                    messageId: chatMessage.messageId,
                                                    sentDate: chatMessage.sentDate,
                                                    kind: .text(messageText),
                                                    updatedID: chatMessage.updatedID)
            super.configure(with: newChatMessage, at: indexPath, and: messagesCollectionView)

            if linkPreviewView.superview == nil {
                linkPreviewView.translatesAutoresizingMaskIntoConstraints = false
                messageContainerView.addSubview(linkPreviewView)
                linkPreviewView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor,
                                                         constant: messageLabel.textInsets.left).isActive = true
                linkPreviewView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor,
                                                          constant: messageLabel.textInsets.right * -1).isActive = true
                linkPreviewView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor,
                                                        constant: messageLabel.textInsets.bottom * -1).isActive = true
            }

            if let linkPreview: ChatLinkPreview = linkPreview, !linkPreview.teaser.isEmptyOrNil {
                linkPreviewView.titleLabel.text = linkPreview.title
                linkPreviewView.teaserLabel.text = linkPreview.teaser
                linkPreviewView.domainLabel.text = linkPreview.domain?.lowercased()

                // Images for link preview are always temporary on the server, so we try to keep this image forever in the cache
                linkPreviewView.imageView.setImage(from: linkPreview.imageURL,
                                                   placeholder: UIImage(named: "link"),
                                                   options: [.diskCacheExpiration(.never),
                                                             .memoryCacheExpiration(.never)])
                self.linkURL = linkURL
            }
        default:
            fatalError("Invalid type for this cell.")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        linkPreviewView.titleLabel.text = nil
        linkPreviewView.teaserLabel.text = nil
        linkPreviewView.domainLabel.text = nil
        linkPreviewView.imageView.image = nil
        linkURL = nil
    }

    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation: CGPoint = convert(gesture.location(in: self), to: linkPreviewView)
        if linkPreviewView.bounds.contains(touchLocation), let url: URL = linkURL {
            delegate?.didSelectURL(url)
            return
        }
        super.handleTapGesture(gesture)
    }
}

fileprivate final class LinkPreviewView: UIView {
    lazy var imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: LinkMessageSizeCalculator.ImageViewSize).isActive = true
        imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true

        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
//        label.font = .caption1SemiBoldFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var teaserLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
//        label.font = .caption2Font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var domainLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
//        label.font = .caption2SemiBoldFont
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentView: UIView = {
        let view: UIView = .init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
                                      constant: LinkMessageSizeCalculator.ImageViewMargin).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        return view
    }()

    init() {
        super.init(frame: .zero)
        contentView.addSubview(titleLabel)
        contentView.addSubview(teaserLabel)
        contentView.addSubview(domainLabel)

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true

        teaserLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        teaserLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3).isActive = true
        teaserLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        teaserLabel.setContentHuggingPriority(.init(249), for: .vertical)

        domainLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        domainLabel.topAnchor.constraint(equalTo: teaserLabel.bottomAnchor, constant: 3).isActive = true
        domainLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        domainLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
