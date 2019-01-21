//
//  DetailsViewController.swift
//  Shopify Challenge 2019
//
//  Created by Julia Pu on 2019-01-20.
//  Copyright © 2019 Julia Pu. All rights reserved.
//

import Foundation
import UIKit

struct ProductData {
    var name: String?
    var quantity: Int?
    var image: String?
    var collection: String?
    
    init(name: String, quantity: Int, image: String, collection: String) {
        self.name = name
        self.quantity = quantity
        self.image = image
        self.collection = collection
    }
}

class ProductTableViewCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productCollectionName: UILabel!
    @IBOutlet weak var productInventory: UILabel!
    
}

class DetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public var collection : CollectionData?
    let collectsURL = "https://shopicruit.myshopify.com/admin/collects.json?collection_id="
    let productURL = "https://shopicruit.myshopify.com/admin/products.json?ids="
    let urlEnd = "&page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    var products: [ProductData] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pageTitle: UINavigationItem!
    
    @IBOutlet weak var topCollectionImage: UIImageView!
    @IBOutlet weak var collectionCardName: UILabel!
    @IBOutlet weak var collectionCardBody: UILabel!
    
    override func viewDidLoad() {
        if let collectionName = collection?.name {
            pageTitle.title = String(collectionName)
        }
        
        tableView.dataSource = self
        tableView.rowHeight = 150
        
        if let imageSrc = collection?.image {
            let url = URL(string: imageSrc)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    self.topCollectionImage.image = UIImage(data: data!)
                }
            }
        }
        collectionCardName.text = collection?.name
        collectionCardBody.text = collection?.body
        
        fetchCollects()
    }
    
    func fetchCollects() {
        guard let collectionID = collection?.id else {
            return
        }
        guard let url =  URL(string: collectsURL + String(collectionID) + urlEnd) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            self.parseCollectsData(data: data)
            
        }.resume()
        
    }
    
    func parseCollectsData(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
            print("Not containing JSON")
            return
        }
        
        if let array = json["collects"] as? [[String: Any]] {
            for product in array {
                let newProductID = product["product_id"] as! Int
                self.fetchProduct(id: newProductID)
            }
        }
    }
    
    func fetchProduct(id: Int) {
        guard let url =  URL(string:productURL + String(id) + urlEnd) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let data = data else {
                return
            }
            
            self.parseProductData(data: data)
            
            //reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
    }
    
    func parseProductData(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
            print("Not containing JSON")
            return
        }
        
        if let array = json["products"] as? [[String: Any]] {
            for product in array {
                let newProductName = product["title"] as! String
                let productCollectionName = collection?.name
                let productImage = product["image"] as! [String: Any]
                let productImageSrc = productImage["src"] as! String
                
                let variants = product["variants"] as! [[String: Any]]
                var totalNum = 0
                for variant in variants {
                    let quantity = variant["inventory_quantity"] as! Int
                    totalNum = totalNum + quantity
                }
                
                let newProduct = ProductData(name: newProductName, quantity: totalNum, image: productImageSrc, collection: productCollectionName!)
                products.append(newProduct)
            }
        }
    }
    
    //table view delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath)
            as! ProductTableViewCell
        if let name = products[indexPath.row].name {
            cell.productName.text = name
        }
        if let imageSrc = products[indexPath.row].image {
            let url = URL(string: imageSrc)
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    cell.productImageView.image = UIImage(data: data!)
                }
            }
        }
        if let collectionName = products[indexPath.row].collection {
            cell.productCollectionName.text = collectionName
        }
        if let quantity = products[indexPath.row].quantity {
            cell.productInventory.text = "Total Available: " + String(quantity)
        }
        cell.isUserInteractionEnabled = false
        return cell
    }
    
}
