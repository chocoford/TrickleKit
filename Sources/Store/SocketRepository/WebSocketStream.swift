//
//  WebSocketStream.swift
//  TrickleKit
//
//  Created by Chocoford on 2022/12/10.
//

import Foundation
import Logging

enum WebSocketStreamError: Error {
    case encodingError
}

class WebSocketStream: NSObject, AsyncSequence {
    typealias Element = URLSessionWebSocketTask.Message
    typealias AsyncIterator = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>.Iterator
    func makeAsyncIterator() -> AsyncIterator {
        guard let stream = stream else {
             fatalError("stream was not initialized")
         }
         socket.resume()
         listenForMessages()
         return stream.makeAsyncIterator()
    }
    
    private let logger = Logger(label: "WebSocketStream")
    
    private var stream: AsyncThrowingStream<Element, Error>?
    private var continuation: AsyncThrowingStream<Element, Error>.Continuation?
    private let socket: URLSessionWebSocketTask
    
    private var waitingList: [any Codable] = []
    
    /// indicate the web socket is open
    private(set) var isSocketOpen: Bool = false {
        didSet {
            if isSocketOpen {
                Task {
                    for message in waitingList {
                        await send(data: message)
                    }
                }
            }
        }
    }
    /// indicate `WebSocketStream` to start clear waitlist.
    public var isSocketReady: Bool = false
        
    var status: URLSessionTask.State {
        socket.state
    }
    
    public var closeCode: String {
        String(describing: socket.closeCode)
    }
    
    public var closeReason: String {
        guard let reason = socket.closeReason else { return "Unknown" }
        let json = try? JSONSerialization.jsonObject(with: reason)
        return String(describing: json)
    }
    
    init(url: URL, session: URLSession = URLSession.shared) {
        logger.info("initing websocket: \(url.description)")
        socket = session.webSocketTask(with: url)
        super.init()
        
        socket.delegate = self
        stream = AsyncThrowingStream { continuation in
            self.continuation = continuation
            self.continuation?.onTermination = { @Sendable [socket] _ in
                socket.cancel()
            }
        }
    }
    
    func ping() {
        socket.sendPing { [weak self] error in
            if let error = error {
                self?.logger.error("ping error: \(error)")
            } else {
                self?.logger.info("pong!")
            }
        }
    }
    
    private func listenForMessages() {
        socket.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
                case .success(let message):
                    self.continuation?.yield(message)
                    self.listenForMessages()
                case .failure(let error):
                    self.continuation?.finish(throwing: error)
            }
        }
    }
    
    private func waitForMessages() async {
        do {
            let message = try await socket.receive()
            continuation?.yield(message)
            await waitForMessages()
        } catch {
            continuation?.finish(throwing: error)
        }
    }
}

extension WebSocketStream {
    public func send(data: Codable) async {
//        guard isSocketOpen else {
//            waitingList.append(data)
//            return
//        }
        socket.resume()
        do {
            logger.error("send data: \(String(describing: data))")
            let data = try JSONEncoder().encode(data)
            try await socket.send(.data(data))
        } catch {
            logger.error("\(error)")
        }
    }
    
    public func send(message: Codable, force: Bool = false) async {
//        guard isSocketOpen else {
//            waitingList.append(message)
//            return
//        }
        socket.resume()
        do {
            logger.error("send message: \(String(describing: message))")
            let data = try JSONEncoder().encode(message)
            guard let string = String(data: data, encoding: .utf8) else {
                throw WebSocketStreamError.encodingError
            }
            try await socket.send(.string(string))
        } catch {
            logger.error("\(error)")
        }
    }
    
    public func send(message: String) async {
//        guard isSocketOpen else {
//            waitingList.append(message)
//            return
//        }
        socket.resume()
        do {
            logger.error("send message: \(String(describing: message))")
            try await socket.send(.string(message))
        } catch {
            logger.error("\(error)")
        }
    }
    
}

extension WebSocketStream: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web socket opened")
        isSocketOpen = true
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web socket closed, reason: \(self.closeReason)")
        isSocketOpen = false
    }
}
