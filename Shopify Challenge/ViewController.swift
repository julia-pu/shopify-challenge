//
//  ViewController.swift
//  Shopify Challenge
//
//  Created by Julia Pu on 2019-01-19.
//  Copyright © 2019 Julia Pu. All rights reserved.
//

import UIKit
struct CollectionData: Codable {
    var name: String?
    var id: Int?
    var image: String?
    var body: String?
    
    init(name: String, id: Int, image: String, body: String) {
        self.name = name
        self.id = id
        self.image = image
        self.body = body
    }
}

class CollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionName: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    let customCollectionsURL = "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6"
    var collections: [CollectionData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.rowHeight = 150
        fetchCollections()
        tableView.reloadData()

    }
    
    func fetchCollections() {
        guard let url =  URL(string: customCollectionsURL) else {
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
            
            self.parseFetchedData(data: data)
            
            //reload data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.resume()
        
    }
    
    func parseFetchedData(data: Data) {
        guard let json = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
            print("Not containing JSON")
            return
        }
        
        if let array = json["custom_collections"] as? [[String: Any]] {
            for collection in array {
                let image = collection["image"] as! [String: Any]
                let newElement = CollectionData(name: collection["title"] as! String, id: collection["id"] as! Int, image: image["src"] as! String, body: collection["body_html"] as! String)
                collections.append(newElement)
            }
        }
    }
    
    //table view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath)
            as! CollectionTableViewCell
        if let name = collections[indexPath.row].name {
            cell.collectionName.text = name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetails", sender: self)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: false)
        }
    }
    
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let detailsViewController = segue.destination as? DetailsViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    detailsViewController.collection = collections[selectedIndexPath.row]
                    tableView.deselectRow(at: selectedIndexPath, animated: false)
                }
            }
        }
    }
}

