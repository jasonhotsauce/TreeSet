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
        
    }
    
    override func tearDown() {
        
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
    
    func buildTreeWith<E: Comparable>(elements: [E]) throws -> AVLTree<E> {
        let tree = AVLTree<E>()
        for element in elements {
            try tree.insert(element)
        }
        return tree
    }
    
    func testThatItInsertNodesCorrectly() {
        do {
            let tree = try buildTreeWith([10, 20, 30, 40, 50, 25]);
            
            var preorder: [Int] = [Int]()
            preorderTraversal(tree.root, result: &preorder)
            XCTAssertEqual(preorder, [30,20,10,25,40,50], "tree insertion should result as balanced BST")
        } catch TreeAccessError.InvalidNode {
            XCTAssert(false, "Should not throw tree access error")
        } catch {
            XCTAssert(false, "Should not have other errors")
        }
    }
    
    func testThatItIgnoreDuplicateItems() {
        do {
            let tree = try buildTreeWith([10, 20, 30, 40, 50, 25, 25, 40,30]);
            
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
        let tree = try! buildTreeWith([9,5,10,0,6,11,-1,1,2])
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
    
    func testThatItGetsFirstItemCorrectly() {
        let treeSet = try! TreeSet(elements: [9,5,10,0,6,11,-1,1,2])
        XCTAssertEqual(treeSet.getFirst(), -1)
    }
    
    func testThatItGetsLastItemCorrectly() {
        let treeSet = try! TreeSet(elements: [9,5,10,0,6,11,-1,1,2])
        XCTAssertEqual(treeSet.getLast(), 11)
    }
    
    func testThatItSearchCorrectly() {
        let treeSet = try! TreeSet(elements: [9,5,10,0,6,11,-1,1,2])
        XCTAssertTrue(treeSet.contains(11))
        XCTAssertFalse(treeSet.contains(20))
    }
    
    func testThatItImplementsGeneratorTypeCorrectly() {
        let treeSet = try! TreeSet(elements: [9,5,10,0,6,11,-1,1,2])
        var generator = treeSet.generate()
        let first = generator.next()
        XCTAssertEqual(first, -1)
        let second = generator.next()
        XCTAssertEqual(second, 0)
        let third = generator.next()
        XCTAssertEqual(third, 1)
    }
}
