//
//  Layout.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

typealias Constraint = (_ child: UIView, _ other: UIView) -> NSLayoutConstraint

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> [Constraint] where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, keyPath, constant: constant, priority: priority)
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0, priority: UILayoutPriority = .required) -> [Constraint] where Anchor: NSLayoutAnchor<Axis> {
    return [{ view, other in
        let constraint = view[keyPath: keyPath].constraint(equalTo: other[keyPath: toAnchor], constant: constant)
        constraint.priority = priority
        return constraint
    }]
}

func equal<Anchor>(_ keyPath: KeyPath<UIView, Anchor>, multiplier: CGFloat, constant: CGFloat = 0) -> [Constraint] where Anchor: NSLayoutDimension {
    return equal(keyPath, keyPath, multiplier: multiplier, constant: constant)
}

func equal<Anchor>(_ keyPath: KeyPath<UIView, Anchor>, _ toAnchor: KeyPath<UIView, Anchor>, multiplier: CGFloat, constant: CGFloat = 0) -> [Constraint] where Anchor: NSLayoutDimension {
    return [{ view, other in
        view[keyPath: keyPath].constraint(equalTo: other[keyPath: toAnchor], multiplier: multiplier, constant: constant)
    }]
}
func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, to: UIView, constant: CGFloat = 0) -> [Constraint] where Anchor: NSLayoutAnchor<Axis> {
    return equal(keyPath, to: to, keyPath, constant: constant)
}

func equal<Axis, Anchor>(_ keyPath: KeyPath<UIView, Anchor>, to: UIView, _ toAnchor: KeyPath<UIView, Anchor>, constant: CGFloat = 0) -> [Constraint] where Anchor: NSLayoutAnchor<Axis> {
    return [{ view, _ in
        view[keyPath: keyPath].constraint(equalTo: to[keyPath: toAnchor], constant: constant)
    }]
}

func constant<Anchor>(_ keyPath: KeyPath<UIView, Anchor>, constant: CGFloat, priority: UILayoutPriority = .required) -> [Constraint] where Anchor: NSLayoutDimension {
    return [{ view, _ in
        let constraint = view[keyPath: keyPath].constraint(equalToConstant: constant)
        constraint.priority = priority
        return constraint
    }]
}

func pinAllEdges() -> [Constraint] {
    return pinHorizontalEdges() + pinVerticalEdges()
}

func pinHorizontalEdges() -> [Constraint] {
    return equal(\.leadingAnchor) + equal(\.trailingAnchor)
}

func pinVerticalEdges() -> [Constraint] {
    return equal(\.topAnchor) + equal(\.bottomAnchor)
}

func pinToCenter() -> [Constraint] {
    return equal(\.centerXAnchor) + equal(\.centerYAnchor)
}

func pinToCenter(of view: UIView) -> [Constraint] {
    return equal(\.centerXAnchor, to: view) + equal(\.centerYAnchor, to: view)
}

extension UIView {
    func addSubview(_ child: UIView, constraints: [[Constraint]]) {
        addSubview(child)
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints.flatMap { $0.map { $0(child, self) } })
    }
}
