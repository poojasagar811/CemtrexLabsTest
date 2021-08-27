//
//  APIManager.swift
//  CemtrexLabsTest
//
//  Created by Pooja's MacBook Pro on 27/08/21.
//

import Foundation

class APIManager {
    
    //MARK: Singelton
    
    static let shared = APIManager()
    private init() {}
    var details : [Details] = []
    var defaultSession = URLSession(configuration: .default)
    var dataTask : URLSessionDataTask?
    var errorMessage = ""
    
    // http request
    let urlString = "https://api.foursquare.com/v2/venues/search?ll=40.7484,-73.9857&oauth_token=NPKYZ3WZ1VYMNAZ2FLX1WLECAWSMUVOQZOIDBN53F3LVZBPQ&v=20180616"
    
    //MARK: API Call
    func callAPI(onCompletion: @escaping (Bool, String?) -> Void)  {
        dataTask?.cancel()
        
        guard let url = URL(string: urlString) else { return }
        
        dataTask = defaultSession.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                onCompletion(false, error.localizedDescription)
            } else if let data  = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                var response : [String : Any]?
                // JsonSerialization class use to serialize the data to Json
                do {
                    response =  try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                } catch let error as NSError {
                    self.errorMessage = error.localizedDescription
                }
                
                guard let responseDict = response else { return }
                guard let  responseDictionary = responseDict["response"] as? [String : Any]  else { return }
                guard let  detailsArray = responseDictionary["venues"] as? Array<Any> else { return }
                
                // execute code in main queue.
                self.getResponse(responseArray: detailsArray)
                DispatchQueue.main.async {
                    onCompletion(true, self.errorMessage)
                }
            }
        })
        // resume to start exicuting a network request.
        dataTask?.resume()
    }
    
    func getResponse(responseArray: Array<Any>) {
        for responseDict in responseArray {
            if let detailDict = responseDict as? [String : Any],
                let id = detailDict["id"] as? String,
                let name = detailDict["name"] as? String {
                details.append(Details(id: id, name: name))
            }
        }
    }
    
}
