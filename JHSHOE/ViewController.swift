//
//  ViewController.swift
//  JHSHOE
//
//  Created by 송정훈 on 2020/10/06.
//

import UIKit
class ViewController: UIViewController {
    var items:[item] = []
    @IBOutlet weak var searchText:UITextField!
    @IBOutlet weak var talbleView:UITableView!
    @IBAction func buttonTapped(_ sender: Any){
        guard var search = searchText.text else {return}
        searchAPI.searching(search: search){items in
            DispatchQueue.main.async {
                self.items = items
                self.talbleView.reloadData()
            }
            print("\(items.count)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

}
extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell",for: indexPath) as? tableViewCell else { return UITableViewCell() }
        let item = items[indexPath.item]
        var title = item.title
        title = title.replacingOccurrences(of: "<b>", with: "")
        title = title.replacingOccurrences(of: "</b>", with: "")
        cell.titleText.text = title
        cell.cafeTitle.text = item.cafename
        cell.cafeURL = item.cafeurl
        return cell
    }
}

class searchAPI{
    static func searching(search:String,completion: @escaping([item]) -> Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var urlComponents = URLComponents(string:"https://openapi.naver.com/v1/search/cafearticle.json?")!
        let mainQuery = URLQueryItem(name: "query", value: search)
        //        let displayQuery = URLQueryItem(name: "display", value: <#T##String?#>) //검색 결과 출력 건수
        //        let startQuery = URLQueryItem(name: "start", value: <#T##String?#>) //검색 시작 위치
        let sortQuery = URLQueryItem(name: "sort", value:"sim") //정렬 옵션:sim(유사도순)date(날짜순)
        urlComponents.queryItems?.append(mainQuery)
        urlComponents.queryItems?.append(sortQuery)
        let requestQuery = urlComponents.url!
        var requestURL = URLRequest(url: requestQuery)
        requestURL.httpMethod = "GET"
        requestURL.setValue("S5nJPDfj70UTlc13PZ5a", forHTTPHeaderField: "X-Naver-Client-Id")
        requestURL.setValue("1OH2J4GBeE", forHTTPHeaderField: "X-Naver-Client-Secret")
       
        print("Request URL:\(requestURL)")

        DispatchQueue.main.async {
            let dataTask = session.dataTask(with: requestURL){(data,response,error) in
                guard error == nil else{ return }
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
                let successRange = 200 ..< 300
                guard successRange.contains(statusCode) else { return }
                guard let resultData = data else { return }
                var resultString = String(data:resultData,encoding: .utf8)
                let items = parseItem(resultData)
                print("Data-->\(resultString)")
                completion(items)
            }
            dataTask.resume()
        }
        
    }
    static func parseItem(_ data:Data) -> [item] {
        let decoder = JSONDecoder()
        do{
            let response = try decoder.decode(channel.self, from: data)
            let item = response.items
            return item
        }catch let error {
            print("-->error:\(error.localizedDescription)")
            return []
        }
    }
}
struct channel: Codable{
    let total:Int
    let display:Int
    let items:[item]
    enum CodingKeys:String,CodingKey {
        case total
        case display
        case items = "items"
    }
}
struct item: Codable {
    let title:String
    let link:String
    let description:String
    let cafename:String
    let cafeurl:String
    enum Codingkeys:String,CodingKey{
        case title
        case link
        case description
        case cafename
        case cafeurl
    }
}
class tableViewCell:UITableViewCell{
    @IBOutlet weak var titleText:UILabel!
    @IBOutlet weak var cafeTitle:UILabel!
    var cafeURL:String!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}



