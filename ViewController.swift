//
//  ViewController.swift
//  Tinkoff_News
//
//  Created by Антон Шуплецов on 16/05/2019.
//  Copyright © 2019 Антон Шуплецов. All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration


class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var dict : [String: Int] = [:]
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var newsArray : [NewsCoreData] = []

    
    struct Welcome: Codable {
        let response: Response
    }
    
    struct Response: Codable {
        let news: [News]
        let total: Int
    }
    
    struct News: Codable {
        let id : String
        let title: String
        let slug: String
    }
    var arr : [News] = []
    
    
    lazy var refresher : UIRefreshControl = {
        saveContext()
        loadData()

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(requestData), for: .valueChanged)
        return refreshControl
        
    }()
    
    @objc
    func requestData(){
       
        parseInfo()
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.parseInfo()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.refreshControl = refresher
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CheckInternetConnection()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        
        
        if segue.identifier == "segue" {
//            print("a")
            let destinationVC = segue.destination as! TextViewController

            destinationVC.newsInfo = sender as! String

        }

        
    }
//    MARK: - Working with model
    
    func saveContext () {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func loadData(){
        let request: NSFetchRequest<NewsCoreData> = NewsCoreData.fetchRequest()
        //        let sd = NSSortDescriptor(key: "name", ascending: true)
        do {
            newsArray = try context.fetch(request)
        } catch {
            print("Error -> \(error)")
        }
        //tableView.reloadData()
    }
    
    //MARK: - Parse json from url
    func parseInfo(){
        

       
            let urlString = "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticles"
            
            guard let url = URL(string: urlString) else { return }
            
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
                //            guard let data = data else {return}
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // Если есть данные - работаем с ними
                if let data = data {
                    // надо получить JSON из полученной даты
                    do {
                        let json = try JSONDecoder().decode(Welcome.self, from: data)
                        self.arr = json.response.news
                        
                        
             

                        
                        
                        DispatchQueue.main.async {
                                 self.tableView.reloadData()
                        }
                    } catch let error{
                        print(error)
                    }
                    
                }}
            task.resume()
        
        
        let deadline = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.refresher.endRefreshing()
        }
    }
    
   
    
    func findCounterFromCD(id: String) -> Int64{
        var counter : Int64 = 0
        for el in newsArray{
            if el.id == id{
                counter = el.transations
            }
          
        }
        return counter
    }
    
    
    private func CheckInternetConnection(){
        if Reachability.isConnectedToNetwork(){
            
            print("Internet Connection Available!")
            
            
        }else{
            
            print("Internet Connection is lost")
        }
    }
    
}
private class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
    

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        

             return arr.count
       
     
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        return "News"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell

        var counter : Int64 = findCounterFromCD(id: self.arr[indexPath.row].id)
        counter += 1
//        dict.updateValue(counter, forKey: arr[indexPath.row].id)
//
            let newNews = NewsCoreData(context: self.context)
            newNews.transations = Int64(counter)
            newNews.id = arr[indexPath.row].id
      
      
        self.saveContext()
        self.loadData()
        tableView.reloadData()
        
        
        
       performSegue(withIdentifier: "segue", sender: arr[indexPath.row].slug )
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
   

            
                cell.newsTitleLabel.text = self.arr[indexPath.row].title
                
                self.loadData()
                let counter = findCounterFromCD(id: self.arr[indexPath.row].id)
                
                cell.counterLabel.text = String(counter)
      
            
        
//        if let id = dict[arr[indexPath.row].id]{
//            cell.counterLabel.text = String(id)
//        } else{
//        dict.updateValue(0, forKey: arr[indexPath.row].id)
//        }
//
  
    return cell
    }
}
