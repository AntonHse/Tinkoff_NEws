//
//  TextViewController.swift
//  Tinkoff_News
//
//  Created by Антон Шуплецов on 18/05/2019.
//  Copyright © 2019 Антон Шуплецов. All rights reserved.
//

import UIKit
import Foundation
class TextViewController: UIViewController {

    
    var newsInfo : String = ""
    var text : String = ""
    
    @IBOutlet weak var TextView: UITextView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    struct Text : Codable{
        let response: Response
    }
    
    
    // MARK: - Response
    struct Response : Codable{
        let text: String
        let textshort: String
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       parseText(plug: newsInfo)
    }
    
    func parseText(plug: String){
        
      
        
        let urlString = "https://cfg.tinkoff.ru/news/public/api/platform/v1/getArticle?urlSlug=\(plug)"
        
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
                    let json = try JSONDecoder().decode(Text.self, from: data)
                    self.text = json.response.text
                    
                    DispatchQueue.main.async {
                        if let result = self.text.htmlAttributedString?.string {
                        self.TextView.text = result
                        }
                    }
                } catch let error{
                    print(error)
                }
                
            }}
        task.resume()
    }
    
}
extension String {
    /// Converts HTML string to a `NSAttributedString`
    
    var htmlAttributedString: NSAttributedString? {
        return try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
