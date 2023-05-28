//
//  GalleryBlockView.swift
//  TrickleKit
//
//  Created by Chocoford on 2023/2/20.
//

import SwiftUI
import ChocofordUI
import TrickleCore

struct GalleryBlockView: View {
    var block: TrickleData.Block
    var focused: Binding<Bool>?
    var onKeydown: ((KeyboardEvent) -> Void)?
    
    @State private var viewSize: CGSize = .zero
    @State private var isHover: Bool = false
    
    let radius: CGFloat = 4
    
    private var isFocused: Binding<Bool> {
        Binding {
            focused?.wrappedValue ?? false
        } set: { val in
            if let focused = focused {
                focused.wrappedValue = val
            }
        }
    }
    
    var body: some View {
        ZStack {
            keyHandler
            content
            toolbar
                .opacity(isHover ? 1 : 0)
        }
        .onHover{ hover in
            withAnimation {
                isHover = hover
            }
        }
#if os(macOS)
        .background(Color(nsColor: .underPageBackgroundColor).opacity(0.3))
#endif
        .overlay(isFocused.wrappedValue ? .indigo.opacity(0.1) : .clear)
#if os(macOS)
        .overlay(RoundedRectangle(cornerRadius: radius).stroke(isFocused.wrappedValue ? .indigo : Color(nsColor: .underPageBackgroundColor)))
#endif
        .clipShape(RoundedRectangle(cornerRadius: radius))
#if os(macOS)
        .onChange(of: isFocused.wrappedValue) { newValue in
            if newValue {
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
#endif
        .onTapGesture {
            isFocused.wrappedValue = true
        }
    }
    
    @ViewBuilder private var content: some View {
        if block.elements?.count == 1,
           let element = block.elements?.first,
           case .galleryImageValue(let imageValue) = element.value {
            SingleAxisGeometryReader(axis: .horizontal) { width in
                switch imageValue {
                    case .local(let localValue):
                        let height = localValue.naturalHeight / localValue.naturalWidth * width
                        ImageElementView(element: element)
                            .frame(width: nil, height: height)
                            
                    case .air(let airValue):
                        let height = airValue.naturalHeight != nil && airValue.naturalWidth != nil ? airValue.naturalHeight! / airValue.naturalWidth! * width : nil
                        ImageElementView(element: element)
                            .frame(width: nil, height: height)
                            
                }
            }
        } else {
            if #available(macOS 13.0, iOS 15.0, *) {
                galleryGrid
            } else {
                // Fallback on earlier versions
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(block.elements ?? []) { element in
                            ImageElementView(element: element)
                        }
                    }
                }
            }

        }
    }
    
    @available(macOS 13.0, iOS 15.0, *)
    @ViewBuilder
    private var galleryGrid: some View {
        if let elements: [TrickleData.Element] = block.elements {
            if elements.count % 3 == 0 || elements.count > 4 {
                let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns) {
                    ForEach(elements) { element in
                        squareImageElement(element)
                    }
                }
            } else if elements.count % 2 == 0 {
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns) {
                    ForEach(elements) { element in
                        squareImageElement(element)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func squareImageElement(_ element: TrickleData.Element) -> some View {
        SingleAxisGeometryReader(axis: .horizontal) { width in
            ImageElementView(element: element, contentMode: .fill)
                .frame(width: width, height: width)
                .clipped()
        }
    }
    
    @ViewBuilder private var toolbar: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
            .padding()
            Spacer()
        }
    }
    
    @ViewBuilder private var keyHandler: some View {
        if let onKeydown = onKeydown, isFocused.wrappedValue {
            Group {
                Button(action: { onKeydown(.enter) }) {}
                    .keyboardShortcut(.escape, modifiers: [])
                Button(action: { onKeydown(.arrowUp) }) {}
                    .keyboardShortcut(.upArrow, modifiers: [])
                Button(action: { onKeydown(.arrowDown)}) {}
                    .keyboardShortcut(.downArrow, modifiers: [])
            }.opacity(0)
        }
    }
}



#if DEBUG
struct GalleryBlockView_Previews: PreviewProvider {
    static var previews: some View {
        GalleryBlockView(block: .init(type: .gallery, elements: [
            .init(.image, value: .galleryImageValue(.air(.init(url: "https://devres.trickle.so/upload/users/50356547938680833/workspaces/76957788663709699/1675312457501/%E6%88%AA%E5%B1%8F2023-02-02%2012.32.26.png",
                                                               name: "image"))))
        ]), focused: .constant(false))
        .frame(width: 400, height: 260)
    }
}
#endif
