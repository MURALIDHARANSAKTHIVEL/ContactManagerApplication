//
//  Extension.swift
//  ContactManager
//
//  Created by Muralidharan Sakthivel on 11/14/21.
//

import Foundation
import UIKit
/// Cusotm Extension implemeanted in this files.
extension Data {
    func toString() -> String { return String(decoding: self, as: UTF8.self) }
}
extension String {
    func toData() -> Data { return Data(self.utf8)}
    
    public var rapidSemiBoldNSAttributeString: NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        style.lineSpacing = 10
        let atttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.paragraphStyle: style]
        return NSMutableAttributedString.init(string: self, attributes: atttrs)
    }
}

extension UIImage {
    func imageResize( withSize newSize:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.automatic)
    }
}
extension UIImageView {
    func load(urlString: String) {
        let url = URL(string: urlString)!
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    
}
/// To add the queryItems
extension Data {
    var toJson: [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: [])
            return json as? [String: Any]
        } catch let error {
            print(error)
            return nil
        }
    }
    var queryItems: [URLQueryItem]? {
        var items = [URLQueryItem]()
        if let json = self.toJson {
            for(key, value) in json {
                var queryValue: String?
                if let double = value as? Double {
                    queryValue = String(double)
                } else {
                    queryValue = value as? String
                }
                items.append(.init(name: key, value: queryValue))
            }
            return items.count > 0 ? items : nil
        }
        return nil
    }
}
