//
//  ViewController.swift
//  JSONDATA
//
//  Created by Dayson Dong on 2019-09-30.
//  Copyright © 2019 Dayson Dong. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension String {
    func getVideoLink() -> String?
    {
        let pattern = "https://videos.bodybuilding.com/video/mp4/[0-9]+/[0-9a-z]+.mp4"
        
        if let res = self.range(of: pattern, options:[.regularExpression, .caseInsensitive]) {
            let link = String(self[res])
            return link
        }
        else {
            return nil
        }
    }
    
    func details() -> [String]
    {
        
        let detailPattern =  "<li class=\"ExDetail-descriptionStep\">[a-z0-9 ,.]{1,}"
        
        if let regex = try? NSRegularExpression(pattern: detailPattern, options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                String(string.substring(with: $0.range).dropFirst("<li class=\"ExDetail-descriptionStep\">".count))
            }
        }
        
        return []
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var count = 0
        var iv = UIImageView(image: nil)
        iv.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
        iv.backgroundColor = .red
        view.addSubview(iv)
        var imageURL: URL?
        var detailLink: URL?
        if let path = Bundle.main.path(forResource: "cardio", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                guard let array = jsonResult as? [[String: Any]] else { print("???"); return }
                print(array.count)
                array.forEach { (exercise) in
                    guard let urlString = exercise["Image_URL_One"] as? String, let linkString = exercise["URL"] as? String , let name = exercise["Exercise_Name"] as? String else { return }
                    guard let url = URL(string: urlString), let link = URL(string: linkString) else { return }
                    imageURL = url
                    detailLink = link

                    
             
                    
                    if detailLink != nil {
                        
                        let request = URLRequest(url: detailLink!)
                        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                            guard error == nil else {
                                print(error?.localizedDescription)
                                return
                            }
                            guard let response = response else {
                                print("no response")
                                return
                            }
                            
                            guard let data = data else {
                                print("no data")
                                return
                            }
                            if let html  = String(data: data, encoding: .utf8) {
//                                print("link \(detailLink)")
                                let testPattern = "level:[\n]*[ ]+[a-zA-Z]+[\n]"
                                //print(test)
                                //print(testPattern)
                                let res = html.range(of: testPattern, options:[.regularExpression, .caseInsensitive])
                                if res != nil {
                                    let trimmed = html[res!].trimmingCharacters(in: CharacterSet.whitespaces)
                                    for c in trimmed {
                                        print(c)
                                    }
                                }
                                
                                //                    if let url = URL(string: html.getVideoLink()!) {
                                //
                                //                        let player = AVPlayer(url: url)
                                //                        let playerLayer = AVPlayerLayer(player: player)
                                //                        playerLayer.frame = self.view.bounds
                                //                        self.view.layer.addSublayer(playerLayer)
                                //                        player.play()
                                
                                
                                //                        DispatchQueue.global(qos: .background).async {
                                //                            if
                                //                                let urlData = NSData(contentsOf: url) {
                                //                                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                                //                                let filePath="\(documentsPath)/tempFile.mp4"
                                //                                DispatchQueue.main.async {
                                //                                    urlData.write(toFile: filePath, atomically: true)
                                //                                    PHPhotoLibrary.shared().performChanges({
                                //                                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                                //                                    }) { completed, error in
                                //                                        if completed {
                                //                                            print("Video is saved!")
                                //                                        }
                                //                                    }
                                //                                }
                                //                            }
                                //                        }
                                //                    }
                            }
                            
                        }
                        task.resume()
                    }
                    
                }
            } catch {
                // handle error
            }
        }
        if imageURL != nil {
            let task = URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, res, error) in
                guard let res = res as? HTTPURLResponse else { return }
                guard error == nil else { return }
                guard res.statusCode == 200 else { return }
                guard let data = data else { return }
                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else  {print("no imaghe"); return  }
                    iv.image = image
                }
            })
            
            //            task.resume()
        }
        
        
    }
    
    
}

