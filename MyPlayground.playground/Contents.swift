//: Playground - noun: a place where people can play

import UIKit

var id = "9022014004490000"
id = (id as NSString).stringByReplacingCharactersInRange(NSRange(location: 3, length: 1), withString: "1")
id = (id as NSString).stringByReplacingCharactersInRange(NSRange(location: id.characters.count - 2, length: 2), withString: "00")