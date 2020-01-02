//
//  ViewController.swift
//  SweetsList
//
//  Created by 小俣幸之助 on 2020/01/02.
//  Copyright © 2020 Konosuke-o. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchText.delegate = self
        searchText.placeholder = "お菓子の名前を入力してください"
        
        tableView.dataSource = self
    }
    
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // tuple
    var sweetList: [(name: String, maker: String, link: URL, image: URL)] = []
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        
        if let searchWord = searchBar.text {
            print(searchWord)
            searchSweets(keyword: searchWord)
        }
    }
    
    struct Sweet: Codable {
        let name: String?
        let maker: String?
        let url: URL?
        let image: URL?
    }
    struct SweetResultJson: Codable {
        let item: [Sweet]
    }
    
    func searchSweets(keyword: String) {
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else {
            return
        }
        print(req_url)
        
        // request obejct
        let req = URLRequest(url: req_url)
        // create session. OperationQueue.main means delegation method or closure is called on main thread.
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        // add task( = request) for session
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            session.finishTasksAndInvalidate() // end session
            
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(SweetResultJson.self, from: data!)
                
                let items = json.item
                self.sweetList.removeAll() // reset
                
                for item in items {
                    if let name = item.name, let maker = item.maker, let link = item.url, let image = item.image {
                        let sweet = (name, maker, link, image)
                        self.sweetList.append(sweet)
                    }
                }
                
                self.tableView.reloadData()
                
                if let sweetdbg = self.sweetList.first {
                    print("----------------")
                    print("list[0] = \(sweetdbg)")
                }
                
            } catch {
                print("error")
            }
        })
        task.resume() // start
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sweetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // retrieve cell object (one line)
        let cell = tableView.dequeueReusableCell(withIdentifier: "sweetCell", for: indexPath)
        
        cell.textLabel?.text = sweetList[indexPath.row].name
        if let imageData = try? Data(contentsOf: sweetList[indexPath.row].image) {
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
}

