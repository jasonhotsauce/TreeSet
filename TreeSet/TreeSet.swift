//
//  TreeSet.swift
//  TreeSet
//
//  Created by Wenbin Zhang on 12/12/15.
//  Copyright © 2015 Wenbin Zhang. All rights reserved.
//

import Foundation

public class TreeSet <E: Comparable> {
    
}

internal class TreeNode <E: Comparable> {
    var element: E
    var height: Int = 1
    var left: TreeNode?
    var right: TreeNode?
    
    init(element: E!) {
        self.element = element;
    }
}

enum TreeAccessError: ErrorType {
    case InvalidNode
}

internal class AVLTree <E: Comparable> {
    
    var root: TreeNode<E>?
    
    internal func insert(newElement: E) throws {
        root = try insertToNode(root, newElement: newElement)
    }
    
    internal func remove(element: E) throws {
        root = try delete(root, element: element)
    }
    
    private func insertToNode(node: TreeNode<E>?, newElement: E) throws -> TreeNode<E> {
        guard let notNilNode = node else {
            return TreeNode(element: newElement)
        }
        if (newElement > notNilNode.element) {
            notNilNode.right = try insertToNode(notNilNode.right, newElement: newElement)
        } else {
            notNilNode.left = try insertToNode(notNilNode.left, newElement: newElement)
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
                let min = minValue(newNode.right!)
                newNode.element = min
                newNode.right = try delete(newNode.right, element: min)
            }
        }
        updateNodeHeight(newNode)
        return try rebalanceTree(newNode)
    }
    
    func minValue(node: TreeNode<E>) -> E {
        guard let leftNotNil = node.left else {
            return node.element
        }
        return minValue(leftNotNil)
    }
    
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
        let rightNode = newNode.right
        newNode.right = node
        node.left = rightNode
        updateNodeHeight(node)
        updateNodeHeight(newNode)
        return newNode
    }
    
    private func leftRotate(node: TreeNode<E>) throws -> TreeNode<E> {
        guard let notNilRight = node.right else {
            throw TreeAccessError.InvalidNode
        }
        let newNode = notNilRight
        let leftNode = newNode.left
        newNode.left = node
        node.right = leftNode
        updateNodeHeight(node)
        updateNodeHeight(newNode)
        return newNode
    }
}