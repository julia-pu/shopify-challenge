//
//  CollectionTableViewCell.swift
//  Shopify Challenge 2019
//
//  Created by Xianglin Liu on 2019-01-19.
//  Copyright © 2019 Julia Pu. All rights reserved.
//

import Foundation
import UIKit

class CollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionName: UILabel!
    
    public func setCollectionName(name: String) {
        collectionName.text = name
    }
    
}
