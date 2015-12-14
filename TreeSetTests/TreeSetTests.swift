//
//  TreeSetTests.swift
//  TreeSetTests
//
//  Created by Wenbin Zhang on 12/12/15.
//  Copyright © 2015 Wenbin Zhang. All rights reserved.
//

import XCTest
@testable import TreeSet

class TreeSetTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func preorderTraversal(node: TreeNode<Int>?, inout result: [Int]) {
        guard let notNilNode = node else {
            return
        }
        result.append(notNilNode.element)
        preorderTraversal(notNilNode.left, result: &result)
        preorderTraversal(notNilNode.right, result: &result)
    }
    
    func testThatItUpdatesTheHeightCorrectly() {
        let root = TreeNode(element: 2)
        let leftNode = TreeNode(element: 1)
        leftNode.left = TreeNode(element: 5)
        let rightNode = TreeNode(element: 3)
        root.left = leftNode
        root.right = rightNode
        XCTAssertEqual(rightNode.height, 1, "root right node height must be 1")
        XCTAssertEqual(root.height, 3, "root height must be 3 here")
        XCTAssertEqual(leftNode.height, 2, "root left node height must be 2")
    }
    
    func testThatItInsertNodesCorrectly() {
        let tree = AVLTree<Int>()
        do {
            try tree.insert(10)
            try tree.insert(20)
            try tree.insert(30)
            try tree.insert(40)
            try tree.insert(50)
            try tree.insert(25)
            
            var preorder: [Int] = [Int]()
            preorderTraversal(tree.root, result: &preorder)
            XCTAssertEqual(preorder, [30,20,10,25,40,50], "tree insertion should result as balanced BST")
        } catch TreeAccessError.InvalidNode {
            XCTAssert(false, "Should not throw tree access error")
        } catch {
            XCTAssert(false, "Should not have other errors")
        }
    }
    
    func testThatItRemoveTheNodeAndTreeStillBalanced() {
        let tree = AVLTree<Int>()
        try! tree.insert(9)
        try! tree.insert(5)
        try! tree.insert(10)
        try! tree.insert(0)
        try! tree.insert(6)
        try! tree.insert(11)
        try! tree.insert(-1)
        try! tree.insert(1)
        try! tree.insert(2)
        do {
            try tree.remove(10)
            var preorder: [Int] = [Int]()
            preorderTraversal(tree.root, result: &preorder)
            XCTAssertEqual(preorder, [1, 0, -1, 9, 5, 2, 6, 11], "after deletion, AVLTree should still be balanced BST")
            try tree.remove(9)
            var preorder2: [Int] = [Int]()
            preorderTraversal(tree.root, result: &preorder2)
            XCTAssertEqual(preorder2, [1,0,-1,5,2,11,6])
        } catch {
            XCTAssert(false, "Should not trigger any errors")
        }
        
    }
}
