//
//  TreeSet.swift
//  TreeSet
//
//  Created by Wenbin Zhang on 12/12/15.
//  Copyright © 2015 Wenbin Zhang. All rights reserved.
//

import Foundation

public struct TreeSet<E: Comparable> {
    
    internal var tree: AVLTree<E>
    public var size: Int {
        get {
            return tree.size
        }
    }
    
    init() {
        tree = AVLTree()
    }
    
    init<C: CollectionType where C.Generator.Element == E>(elements: C) throws {
        self.init()
        do {
            try addAll(elements)
        }
        
    }
    
    func getFirst() -> E? {
        guard let root = tree.root else {
            return nil
        }
        return tree.minNode(root).element
    }
    
    func getLast() -> E? {
        guard let root = tree.root else {
            return nil
        }
        return tree.maxNode(root).element
    }
    
    func contains(element: E) -> Bool {
        return tree.search(element)
    }
    
    private mutating func makeTreeCopyIfNeed() {
        if !isUniquelyReferencedNonObjC(&tree) {
            tree = tree.copy()
        }
    }
    
    mutating func addAll<C: CollectionType where C.Generator.Element == E>(elements: C) throws {
        makeTreeCopyIfNeed()
        for element in elements {
            try tree.insert(element)
        }
    }
    
    mutating func add(element: E) throws {
        makeTreeCopyIfNeed()
        try tree.insert(element)
    }
    
    mutating func remove(element: E) throws {
        makeTreeCopyIfNeed()
        try tree.remove(element)
    }
}

// MARK: - SequenceType
extension TreeSet : SequenceType {
    public typealias Generator = TreeSetGenerator<E>
    
    public func generate() -> Generator {
        return Generator(self)
    }
}

// MARK: - GeneratroType
public struct TreeSetGenerator<E: Comparable>: GeneratorType {
    
    public typealias Element = E
    private let treeSet: TreeSet<E>
    private var currentNode: TreeNode<E>?
    
    init(_ treeSet: TreeSet<E>) {
        self.treeSet = treeSet
    }
    
    public mutating func next() -> Element? {
        guard let rootNode = treeSet.tree.root else {
            return nil
        }
        
        guard let node = currentNode else {
            currentNode = treeSet.tree.minNode(rootNode)
            return currentNode?.element
        }
        currentNode = treeSet.tree.successor(node)
        return currentNode?.element
    }
}

enum TreeAccessError: ErrorType {
    case InvalidNode
}

// MARK: - Node for AVLTree to hold element.
internal class TreeNode<E: Comparable> {
    var element: E
    var height: Int = 1
    var left: TreeNode?
    var right: TreeNode?
    weak var parent: TreeNode?
    
    init(element: E!) {
        self.element = element;
    }
}

extension TreeNode {
    func copy() -> TreeNode {
        let node = TreeNode(element: self.element)
        node.left = self.left?.copy()
        node.left?.parent = node
        node.right = self.right?.copy()
        node.right?.parent = node
        return node
    }
}

// MARK: - Equatable
extension TreeNode: Equatable {}

func ==<E: Comparable>(lhs: TreeNode<E>, rhs: TreeNode<E>) -> Bool
{
    return lhs.element == rhs.element
}

func <<E: Comparable>(lhs: TreeNode<E>, rhs: TreeNode<E>) -> Bool
{
    return lhs.element < rhs.element
}

func <=<E: Comparable>(lhs: TreeNode<E>, rhs: TreeNode<E>) -> Bool {
    return lhs.element <= rhs.element
}

func ><E: Comparable>(lhs: TreeNode<E>, rhs: TreeNode<E>) -> Bool {
    return lhs.element > rhs.element
}

func >=<E: Comparable>(lhs: TreeNode<E>, rhs: TreeNode<E>) -> Bool {
    return lhs.element >= rhs.element
}

// MARK: - AVLTree Implementation
internal class AVLTree <E: Comparable> {
    
    var root: TreeNode<E>?
    private var size: Int = 0
    
    internal func insert(newElement: E) throws {
        do {
            root = try insertToNode(root, newElement: newElement)
            size += 1
        }
        
    }
    
    internal func remove(element: E) throws {
        do {
            root = try delete(root, element: element)
            size -= 1
        }
        
    }
    
    internal func successor(element: TreeNode<E>?) -> TreeNode<E>? {
        guard let node = element else {
            return nil
        }
        if let rightBranch = node.right {
            return minNode(rightBranch)
        } else {
            var p = node.parent
            var child = node
            while (p != nil && child == p!.right) {
                child = p!
                p = p!.parent
            }
            return p
        }
    }
    
    internal func search(element: E) -> Bool {
        var node = root;
        
        while (node != nil) {
            if (node!.element > element) {
                node = node!.left
            } else if (node!.element < element) {
                node = node!.right
            } else {
                return true
            }
        }
        return false
    }
    
    private func insertToNode(node: TreeNode<E>?, newElement: E) throws -> TreeNode<E> {
        guard let notNilNode = node else {
            return TreeNode(element: newElement)
        }
        if (newElement > notNilNode.element) {
            notNilNode.right = try insertToNode(notNilNode.right, newElement: newElement)
            notNilNode.right?.parent = notNilNode
        } else if (newElement < notNilNode.element) {
            notNilNode.left = try insertToNode(notNilNode.left, newElement: newElement)
            notNilNode.left?.parent = notNilNode
        } else {
            return notNilNode
        }
        updateNodeHeight(notNilNode)
        return try rebalanceTree(notNilNode)
    }
    
    private func delete(node: TreeNode<E>?, element: E) throws -> TreeNode<E>? {
        guard var newNode = node else {
            return nil
        }
        if (element > newNode.element) {
            newNode.right = try delete(newNode.right, element: element)
        } else if (element < newNode.element){
            newNode.left = try delete(newNode.left, element: element)
        } else {
            if (newNode.left == nil || newNode.right == nil) {
                if let child = newNode.left == nil ? newNode.right : newNode.left {
                    newNode = child
                } else {
                    return nil
                }
            } else {
                let min = minNode(newNode.right!)
                newNode.element = min.element
                newNode.right = try delete(newNode.right, element: min.element)
            }
        }
        updateNodeHeight(newNode)
        return try rebalanceTree(newNode)
    }
    
    func minNode(node: TreeNode<E>) -> TreeNode<E> {
        guard let leftNotNil = node.left else {
            return node
        }
        return minNode(leftNotNil)
    }
    
    func maxNode(node: TreeNode<E>) -> TreeNode<E> {
        guard let rightNode = node.right else {
            return node
        }
        return maxNode(rightNode)
    }
    
    // MARK: - Private helpers
    private func rebalanceTree(node: TreeNode<E>) throws -> TreeNode<E> {
        let balance = getBalance(node)
        if (balance > 1 && getHeight(node.left?.left) >= getHeight(node.left?.right)) {
            return try leftLeft(node)
        } else if (balance > 1 && getHeight(node.left?.right) > getHeight(node.left?.left)) {
            return try leftRight(node)
        } else if (balance < -1 && getHeight(node.right?.left) >= getHeight(node.right?.right)) {
            return try rightLeft(node)
        } else if (balance < -1 && getHeight(node.right?.right) > getHeight(node.right?.left)) {
            return try rightRight(node)
        }
        
        return node
    }
    
    private func updateNodeHeight(node: TreeNode<E>) {
        let leftHeight = node.left == nil ? 0 : node.left!.height
        let rightHeight = node.right == nil ? 0 : node.right!.height
        node.height = max(leftHeight, rightHeight) + 1
    }
    
    private func getHeight(node: TreeNode<E>?) -> Int {
        guard let notNilNode = node else {
            return 0;
        }
        return notNilNode.height
    }
    
    private func getBalance(node: TreeNode<E>) -> Int {
        return getHeight(node.left) - getHeight(node.right)
    }
    
    private func leftLeft(node: TreeNode<E>) throws -> TreeNode<E> {
        return try rightRotate(node)
    }
    
    private func leftRight(node: TreeNode<E>) throws -> TreeNode<E> {
        node.left = try leftRotate(node.left!)
        return try rightRotate(node)
    }
    
    private func rightRight(node: TreeNode<E>) throws -> TreeNode<E> {
        return try leftRotate(node)
    }
    
    private func rightLeft(node: TreeNode<E>) throws -> TreeNode<E> {
        node.right = try rightRotate(node.right!)
        return try leftRotate(node)
    }
    
    private func rightRotate(node: TreeNode<E>) throws -> TreeNode<E> {
        guard let notNilLeft = node.left else {
            throw TreeAccessError.InvalidNode
        }
        let newNode = notNilLeft
        newNode.parent = node.parent
        let rightNode = newNode.right
        newNode.right = node
        node.parent = newNode
        node.left = rightNode
        rightNode?.parent = node
        updateNodeHeight(node)
        updateNodeHeight(newNode)
        return newNode
    }
    
    private func leftRotate(node: TreeNode<E>) throws -> TreeNode<E> {
        guard let notNilRight = node.right else {
            throw TreeAccessError.InvalidNode
        }
        let newNode = notNilRight
        newNode.parent = node.parent
        let leftNode = newNode.left
        newNode.left = node
        node.parent = newNode
        node.right = leftNode
        leftNode?.parent = node
        updateNodeHeight(node)
        updateNodeHeight(newNode)
        return newNode
    }
}

// MARK: - AVLTree copy
extension AVLTree {
    func copy() -> AVLTree<E> {
        let clone = AVLTree()
        clone.root = self.root?.copy()
        return clone
    }
}