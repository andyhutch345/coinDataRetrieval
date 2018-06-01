//
//  CoinDataRetrieval.swift
//  CryptoTracker
//
//  Created by Andy on 3/30/18.
//  Copyright © 2018 ahutch. All rights reserved.
//

import Foundation

protocol CoinDataRetrievalProtocol: class {
    func returnJson(json:Any, type:String, differentiation: Int?, coinName: String?)
}

class CoinDataRetrieval{
    
    weak var delegate: CoinDataRetrievalProtocol?
    
    //type: price, pricemulti, pricemultifull
    //type: histoday, histohour, histominute
    func getData(symbolIn: [String], symbolOut: [String], type: String, detailType: String, limit: Int?, aggregate: Int?, differentiation: Int?, timestamp: String?){
        
        var tempSymbols: [String] = []
        var allSymbols = symbolIn
        for loops in 0...(allSymbols.count/50){
            tempSymbols.removeAll()
            for i in 0...49{
                if !allSymbols.isEmpty{
                    tempSymbols.append(allSymbols[allSymbols.count-1])
                    allSymbols.remove(at: allSymbols.count-1)
                }else{
                    break
                }
                
            }
            
            let urlString = createURL(symbolIn: tempSymbols, symbolOut: symbolOut, type: type, detailType: detailType, limit: limit, aggregate: aggregate, timestamp: timestamp)
            
            if let url = urlString{
                downloadTask(url: url, detailType: detailType, differentiation: differentiation, firstCoinName: tempSymbols[0])
            }
        }
    }
    
    func createURL(symbolIn: [String], symbolOut: [String], type: String, detailType: String, limit: Int?, aggregate: Int?, timestamp: String?) -> URL? {
        var symbolInStr = ""
        var symbolOutStr = ""
        var concatenatedUrl = ""
        for symbol in symbolIn{
            symbolInStr += symbol + ","
        }
        for symbol in symbolOut{
            symbolOutStr += symbol + ","
        }
        symbolInStr.remove(at: symbolInStr.index(before: symbolInStr.endIndex))
        symbolOutStr.remove(at: symbolOutStr.index(before: symbolOutStr.endIndex))
        
        if type == "price" {
            if detailType == "price"{
                concatenatedUrl = "https://min-api.cryptocompare.com/data/\(detailType)?fsym=\(symbolInStr)&tsyms=\(symbolOutStr)"
            }else{
                concatenatedUrl = "https://min-api.cryptocompare.com/data/\(detailType)?fsyms=\(symbolInStr)&tsyms=\(symbolOutStr)"
            }
        }else if type == "dayAvg"{
            concatenatedUrl = "https://min-api.cryptocompare.com/data/\(detailType)?fsym=\(symbolInStr)&tsym=\(symbolOutStr)&toTs=\(timestamp!)"
        }else{
            concatenatedUrl = "https://min-api.cryptocompare.com/data/\(detailType)?fsym=\(symbolInStr)&tsym=\(symbolOutStr)&limit=\(limit!)&aggregate=\(aggregate!)&e=CCCAGG"
        }
        let urlString = URL(string: concatenatedUrl)
        return urlString
    }
    
    func downloadTask(url: URL,detailType: String, differentiation: Int?, firstCoinName: String){
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Error connecting to the Crypto API")
            } else {
                if let usableData = data {
                    guard let json = try? JSONSerialization.jsonObject(with: usableData, options: .mutableContainers) else {
                        print("Unable to serialize data into JSON")
                        return
                    }
                    self.delegate?.returnJson(json: json, type: detailType, differentiation: differentiation, coinName: firstCoinName)
                }
            }
        }
        task.resume()

    }
}
