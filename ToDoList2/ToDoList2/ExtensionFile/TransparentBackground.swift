//
//  TransparentBackground.swift
//  ToDoList2
//
//  Created by 黃弘諺 on 2022/12/10.
//

import SwiftUI
import Foundation


struct TransparentBackground: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
