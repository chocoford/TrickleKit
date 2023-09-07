//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/7/17.
//

import Foundation


public struct AIAgentConversationSession: Codable, Hashable, Identifiable {
    public let conversationID, agent, agentConfigID: String
    public var messages: [Message]
    public var conversationType: ConversationType?

    public var id: String { conversationID }
    
    public init(
        conversationID: String,
        agent: String,
        agentConfigID: String,
        messages: [Message],
        conversationType: ConversationType? = .workspace
    ) {
        self.conversationID = conversationID
        self.agent = agent
        self.agentConfigID = agentConfigID
        self.messages = messages
        self.conversationType = conversationType
    }
    
    enum CodingKeys: String, CodingKey {
        case conversationID = "conversationId"
        case agent
        case agentConfigID = "agentConfigId"
        case messages
        case conversationType
    }
    
    public enum ConversationType: String, Codable, Hashable {
        case workspace
        case admin
    }
}

extension AIAgentConversationSession {
    // MARK: - Message
    public struct Message: Codable, Identifiable, Hashable {
        public let messageID: String
        public var cardVersion: CardVersion
        public var authorType: AuthorType
        public var messageType: MessageType
        public let actionCards: [ActionCard]
        public let replyToMessageID, text: String
        public var createAt: String
        public var status: Status
        public var conversationID: String?
        public var source: String?
        public var medias: [String]?
        public var ocrs: [String : String]?

        enum CodingKeys: String, CodingKey {
            case messageID = "messageId"
            case cardVersion
            case authorType = "author"
            case messageType, actionCards
            case replyToMessageID = "replyToMessageId"
            case createAt, text, status
            case conversationID = "conversationId"
            case source, medias, ocrs
        }
        
        public var id: String { messageID }
        
        internal init(
            messageID: String = UUID().uuidString,
            messageType: MessageType,
            authorType: AuthorType,
            cardVersion: CardVersion,
            actionCards: [ActionCard],
            replyToMessageID: String,
            createAt: String,
            text: String,
            status: Status,
            conversationID: String? = nil,
            source: String,
            medias: [String],
            ocrs: [String : String]
//            conversationType: ConversationType = .workspace
        ) {
            self.messageID = messageID
            self.messageType = messageType
            self.authorType = authorType
            self.cardVersion = cardVersion
            self.actionCards = actionCards
            self.replyToMessageID = replyToMessageID
            self.createAt = createAt
            self.text = text
            self.status = status
            self.conversationID = conversationID
            self.source = "mac desktop"
            self.medias = medias
            self.ocrs = ocrs
//            self.conversationType = conversationType
        }
        
        public struct OCRPayload {
            public var medias: [String]
            public var ocrs: [String : String]
            
            public init(medias: [String], ocrs: [String : String]) {
                self.medias = medias
                self.ocrs = ocrs
            }
        }
        
        static public func makeUserMessage(text: String, status: Status = .done, source: String, ocrPayload: OCRPayload?) -> Self {
            let id = UUID().uuidString
            return .init(
                messageID: id,
                messageType: .chat,
                authorType: .user,
                cardVersion: .v1,
                actionCards: [
                    .makeUserActionCard(text.replacingOccurrences(of: "\n", with: "\n\n"))
                ],
                replyToMessageID: id,
                createAt: "",
                text: text,
                status: status,
                source: source,
                medias: ocrPayload?.medias ?? [], ocrs: ocrPayload?.ocrs ?? [:]
            )
        }
        
        static public func makeUserMessage(actionCards: ActionCard..., status: Status = .done, source: String, ocrPayload: OCRPayload?) -> Self {
            let id = UUID().uuidString
            return .init(
                messageID: id,
                messageType: .chat,
                authorType: .user,
                cardVersion: .v1,
                actionCards: actionCards,
                replyToMessageID: id,
                createAt: "",
                text: "",
                status: status,
                source: source,
                medias: ocrPayload?.medias ?? [], ocrs: ocrPayload?.ocrs ?? [:]
            )
        }
        
        static public func makeSystemMessage(text: String, source: String) -> Self {
            let id = UUID().uuidString
            return .init(messageID: id,
                         messageType: .chat,
                         authorType: .system,
                         cardVersion: .v1,
                         actionCards: [
                            .init(args: .init(direction: .left, fulfill: true, style: nil),
                                  elements: [.text(.init(args: .init(text: text)))])
                         ],
                         replyToMessageID: id,
                         createAt: "",
                         text: text,
                         status: .done,
                         source: source,
                         medias: [], ocrs: [:])
        }
        
        static public func makeSystemMessage(actionCards: ActionCard..., source: String) -> Self {
            let id = UUID().uuidString
            return .init(messageID: id,
                         messageType: .chat,
                         authorType: .system,
                         cardVersion: .v1,
                         actionCards: actionCards,
                         replyToMessageID: id,
                         createAt: "",
                         text: "",
                         status: .done,
                         source: source,
                         medias: [], ocrs: [:])
        }
        
        static public func makeEmptyMessage(source: String, ocrPayload: OCRPayload?) -> Self {
            let id = UUID().uuidString
            return .init(
                messageID: id,
                messageType: .chat,
                authorType: .user,
                cardVersion: .v1,
                actionCards: [],
                replyToMessageID: id,
                createAt: "",
                text: "",
                status: .done,
                source: source,
                medias: ocrPayload?.medias ?? [], ocrs: ocrPayload?.ocrs ?? [:]
            )
        }
    }
}

extension AIAgentConversationSession.Message {
    // MARK: - ActionCard
    public struct ActionCard: Codable, Identifiable, Hashable {
        public var id: String
        public var args: ActionCardArgs
        public var elements: [Element]

        public init(id: String = UUID().uuidString, args: ActionCardArgs, elements: [Element]) {
            self.id = id
            self.args = args
            self.elements = elements
        }
        
        static public func makeUserActionCard(_ text: String) -> Self {
            self.init(id: UUID().uuidString,
                      args: .init(direction: .right,
                                  fulfill: false,
                                  style: nil),
                      elements: [
                        .text(.init(args: .init(text: text)))
                      ])
        }
    }
    
    // MARK: - MessageType
    public enum MessageType: String, Codable, Hashable {
        case chat = "Chat"
        case form = "Form"
    }
    
    public enum AuthorType: String, Codable, Hashable {
        case user, system, assistant
    }
    
    public enum CardVersion: String, Codable, Hashable {
        case v1
    }
    
    public enum Status: String, Codable, Hashable {
        case generating, done, error
    }
}


//protocol ActionCardElement {
//    public var type: String { get set }
//    public var args: ElementArgs? { get set }
//    public var id: String? { get set }
//    public var children: [Child]? { get set }
//}

extension AIAgentConversationSession.Message.ActionCard {
    public enum Element: Codable, Hashable {
        case text(TextElement)
        case button(ButtonElement)
//        case googleButton
        case group(GroupElement)
        case input(TextFieldElement)
        case textarea(TextareaElement)
        case link(LinkElement)
//        case editor
        case image(ImageElement)
        case icon(IconElement)
        case trickleContent(TrickleContentElement)
        case toggleList(ToggleListElement)
        
        enum CodingKeys: String, CodingKey {
            case type
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let elementType = try container.decode(ElementType.self, forKey: .type)
            
            switch elementType {
                case .text:
                    self = try .text(TextElement(from: decoder))
                case .elements:
                    self = try .group(GroupElement(from: decoder))
                case .button:
                    self = try .button(ButtonElement(from: decoder))
                case .input:
                    self = try .input(TextFieldElement(from: decoder))
                case .textarea:
                    self = try .textarea(TextareaElement(from: decoder))
                case .link:
                    self = try .link(LinkElement(from: decoder))
                case .image:
                    self = try .image(ImageElement(from: decoder))
                case .icon:
                    self = try .icon(IconElement(from: decoder))
                case .card:
                    self = try .trickleContent(TrickleContentElement(from: decoder))
                case .toggleList:
                    self = try .toggleList(ToggleListElement(from: decoder))
                default:
                    print("invalid type", elementType)
                    self = try .init(from: decoder)
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
                case .text(let element):
                    try container.encode(element)
                case .button(let element):
                    try container.encode(element)
                case .group(let element):
                    try container.encode(element)
                case .input(let element):
                    try container.encode(element)
                case .textarea(let element):
                    try container.encode(element)
                case .link(let element):
                    try container.encode(element)
                case .image(let element):
                    try container.encode(element)
                case .icon(let element):
                    try container.encode(element)
                case .trickleContent(let element):
                    try container.encode(element)
                case .toggleList(let element):
                    try container.encode(element)
            }
        }
    }
    // MARK: - ElementArgs
    public struct ElementArgs: Codable {
        public let text: String
        public let cursor, value: Bool?
        public let style: CSSStyle?

        public init(text: String, cursor: Bool?, value: Bool?, style: CSSStyle?) {
            self.text = text
            self.cursor = cursor
            self.value = value
            self.style = style
        }
    }
    
    // MARK: - ActionCardArgs
    public struct ActionCardArgs: Codable, Hashable {
        public let direction: Direction?
        public let fulfill: Bool?
        public let style: CSSStyle?

        public enum Direction: String, Codable, Hashable {
            case left, right
        }
        
        public init(direction: Direction?, fulfill: Bool?, style: CSSStyle?) {
            self.direction = direction
            self.fulfill = fulfill
            self.style = style
        }
        
        public static var `nil`: Self { .init(direction: nil, fulfill: nil, style: nil) }
    }

    // MARK: - CSSStyle
    public struct CSSStyle: Codable, Hashable {
        public let background, boxShadow: String?
        public let padding: PaddingValue?
        public let marginTop: String?
        public let fontSize, color: String?

        enum CodingKeys: String, CodingKey {
            case background, boxShadow, padding
            case marginTop = "margin-top"
            case fontSize = "font-size"
            case color
        }
        
        public enum PaddingValue: Codable, Hashable {
            case int(Int)
            case string(String)
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                
                if let x = try? container.decode(Int.self) {
                    self = .int(x)
                } else if let x = try? container.decode(String.self) {
                    self = .string(x)
                } else {
                    throw DecodingError.typeMismatch(PaddingValue.self,
                                                     DecodingError.Context(codingPath: decoder.codingPath,
                                                                           debugDescription: "Wrong type for PaddingValue"))
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                fatalError("Not implement")
            }
        }
    }
}

public protocol ActionCardElement: Codable, Identifiable, Hashable {
    associatedtype Args: Codable
//    var id: String { get set }
    var type: AIAgentConversationSession.Message.ActionCard.Element.ElementType { get set }
    var args: Args? { get set }
}

// MARK: - Element Type
extension AIAgentConversationSession.Message.ActionCard.Element {
    public enum ElementType: String, Codable {
        case button = "button"
        case googleButton = "googleButton"
        case text = "text"
        case input = "input"
        case textarea = "textarea"
        case link = "link"
        case editor = "editor"
        case elements = "elements"
        case image = "image"
        case icon = "icon"
        case iconButton = "iconButton"
        case loading = "loading"
        case translator = "translator"
        case task = "task"
        case card = "card"
        case dropdown = "dropdown"
        case toggleList = "toggleList"
        case blocks = "blocks"
    }
    
    public struct TextElement: ActionCardElement {
        public var id: String? = UUID().uuidString
        public var type: ElementType = .text
        public var args: Args?
        
        public struct Args: Codable, Hashable {
            public var text: String
        }
        
        init(id: String? = UUID().uuidString, args: Args? = nil) {
            self.id = id
            self.args = args
        }
    }
    
    public struct GroupElement: ActionCardElement {
        public var id: String
        public var type: ElementType = .elements
        public var args: Args?
        public var children: [AIAgentConversationSession.Message.ActionCard.Element]
        
        public struct Args: Codable, Hashable {}
    }
    
    public struct ButtonElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        
        public struct Args: Codable, Hashable {
            
        }
    }
    
    public struct TextFieldElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        
        public struct Args: Codable, Hashable {
            public var value: String
            public var placeholder: String?
            public var disabled: Bool?
        }
    }
    
    public struct TextareaElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        
        public struct Args: Codable, Hashable {
            public var value: String
            public var placeholder: String?
            public var disabled: Bool?
        }
    }
    
    public struct LinkElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        
        public struct Args: Codable, Hashable {
            public var text: String
            public var href: String?
        }
    }
    
    public enum ImageElement: Codable, Hashable {
        case local(LocalImageElement)
        case air(AirImageElement)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self = .air(try container.decode(AirImageElement.self))
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
                case .air(let element):
                    try container.encode(element)
                case .local:
                    fatalError("Do not encode local image.")
            }
        }
        
        public struct AirImageElement: ActionCardElement {
            public var id: String
            public var type: ElementType
            public var args: Args?
            
            public struct Args: Codable, Hashable {
                public var urlString: String?
                public var size: CGFloat?
                public var text: String?
                public var rounded: Bool?
                public var bordered: Bool?
                
                enum CodingKeys: String, CodingKey {
                    case urlString = "url"
                    case size
                    case text
                    case rounded
                    case bordered
                }
            }
            
            public init(urlString: String) {
                self.id = UUID().uuidString
                self.type = .image
                self.args = .init(urlString: urlString)
            }
        }
        public struct LocalImageElement: Codable, Hashable {
            public var nsImageData: Data
            
            public init(data: Data) {
                self.nsImageData = data
            }
        }
    }
    
    public struct IconElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        public struct Args: Codable, Hashable {
            public var icon: String?
            public var color: String?
            public var size: String?
            
            public init(icon: String?, color: String? = nil, size: String? = nil) {
                self.icon = icon
                self.color = color
                self.size = size
            }
        }
        
        public init(id: String = UUID().uuidString, args: Args?) {
            self.id = id
            self.type = .icon
            self.args = args
        }
    }
    
    public struct TaskElement: ActionCardElement {
        public var id: String
        public var type: ElementType = .task
        public var args: Args?
        public struct Args: Codable, Hashable {
            public var value: [TrickleData]
            public var fieldInfo: [GroupData.FieldInfo]
        }
    }
    
    public struct TrickleContentElement: ActionCardElement {
        public var id: String
        public var type: ElementType = .card
        public var args: Args?
        public struct Args: Codable, Hashable {
            public var value: TrickleData
            public var hideAvatar: Bool?
        }
    }
    
    public struct ToggleListElement: ActionCardElement {
        public var id: String
        public var type: ElementType
        public var args: Args?
        public var children: [AIAgentConversationSession.Message.ActionCard.Element]?
        
        public struct Args: Codable, Hashable {
            public var value: Bool
            public var text: String?
        }
    }
}

extension AIAgentConversationSession.Message.ActionCard.Element {
    // MARK: - Child
    public struct Child: Codable {
        public let id, type: String
        public let args: ChildArgs

        public init(id: String, type: String, args: ChildArgs) {
            self.id = id
            self.type = type
            self.args = args
        }
    }

    // MARK: - ChildArgs
    public struct ChildArgs: Codable {
        public let text: String?
        public let cursor: Bool?
        public let icon, color, size: String?

        public init(text: String?, cursor: Bool?, icon: String?, color: String?, size: String?) {
            self.text = text
            self.cursor = cursor
            self.icon = icon
            self.color = color
            self.size = size
        }
    }
}
