//
//  ViewController.swift
//  nasa-photo-gallery
//
//  Created by Shruti S on 29/12/25.
//

import UIKit
import Foundation

var imgUrlString = ""

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var copyrightLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var isScrollViewHidden = false {
        didSet {
            DispatchQueue.main.async {
                self.scrollView.isHidden = self.isScrollViewHidden
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if isScrollViewHidden {
            DispatchQueue.main.async {
                self.scrollView.isHidden = self.isScrollViewHidden
            }
        }
        
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.2
        
        dateLabel.numberOfLines = 1
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.2
        
        descriptionLabel.numberOfLines = 0
        
        imgView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        imgView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleImageTap(_ gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toImageDetailsVC", sender: nil)
    }

    
    func getSelectedDate() -> String {
        var selectedDate = self.datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: selectedDate)
        
        return dateString
    }

    func getDataFromNasaApi() {
        let selectedDate = getSelectedDate()
        
        let urlString = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&date=" + selectedDate
        
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                self.showErrorAlert(alertMsg: error.localizedDescription)
                return
            }
            
            guard let data = data else {
                self.showErrorAlert(alertMsg: "API call failed")
                return
            }
            
            self.isScrollViewHidden = false
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                print(jsonObject)
                
                DispatchQueue.main.async {
                    self.titleLabel.text = jsonObject?["title"] as? String
                    self.dateLabel.text = jsonObject?["date"] as? String
                    self.descriptionLabel.text = jsonObject?["explanation"] as? String
                    self.copyrightLabel.text = "Copyright" +  (jsonObject?["copyright"] as? String ?? "")
                }
                imgUrlString = jsonObject?["url"] as? String ?? ""
                
                self.imgView.load(url: (URL(string: imgUrlString) ?? URL(string: ""))!)
            } catch {
                print("JSON decoding error: \(error)")
            }
             
             
        }
        task.resume()
        
    }
    
    func fillDataFromSampleResponse() {
       
            
            DispatchQueue.main.async {
                self.titleLabel.text = "M1: The Crab Nebula"
                self.dateLabel.text = "2025-12-29"
                self.descriptionLabel.text = "This is the mess that is left when a star explodes.  The Crab Nebula, the result of a supernova seen in 1054 AD, is filled with mysterious filaments.  The filaments are not only tremendously complex but appear to have less mass than expelled in the original supernova and a higher speed than expected from a free explosion.  The featured image was taken by an amateur astronomer in Leesburg, Florida, USA over three nights last month. It was captured in three primary colors but with extra detail provided by specific emission by hydrogen gas. The Crab Nebula spans about 10 light years.  In the Nebula's very center lies a pulsar: a neutron star as massive as the Sun but with only the size of a small town.  The Crab Pulsar rotates about 30 times each second.   Explore the Universe: Random APOD Generator"
                self.copyrightLabel.text = "Copyright " +  "Alan Chen"
            }
            imgUrlString = "https://apod.nasa.gov/apod/image/2512/Crab_Chen_960.jpg"
        
        self.imgView.load(url: (URL(string: imgUrlString) ?? URL(string: ""))!)
        
    }
    
    @IBAction func loadImageButtonClicked(_ sender: Any) {
        //self.isScrollViewHidden = !isScrollViewHidden
        
        //getDataFromNasaApi()
        fillDataFromSampleResponse()
    }
    
    func showErrorAlert (alertMsg: String) {
        let alert = UIAlertController(title: "Error", message: alertMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIImageView {
    func load(url: URL) {
        // Perform the network request on a background thread
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    // Update the UI (set the image) on the main thread
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}


var sampleJSON = """
{
"copyright": "\nAlan Chen\n",
"date": "2025-12-29",
"explanation": "This is the mess that is left when a star explodes.  The Crab Nebula, the result of a supernova seen in 1054 AD, is filled with mysterious filaments.  The filaments are not only tremendously complex but appear to have less mass than expelled in the original supernova and a higher speed than expected from a free explosion.  The featured image was taken by an amateur astronomer in Leesburg, Florida, USA over three nights last month. It was captured in three primary colors but with extra detail provided by specific emission by hydrogen gas. The Crab Nebula spans about 10 light years.  In the Nebula's very center lies a pulsar: a neutron star as massive as the Sun but with only the size of a small town.  The Crab Pulsar rotates about 30 times each second.   Explore the Universe: Random APOD Generator",
"hdurl": "https://apod.nasa.gov/apod/image/2512/Crab_Chen_1920.jpg",
"media_type": "image",
"service_version": "v1",
"title": "M1: The Crab Nebula",
"url": "https://apod.nasa.gov/apod/image/2512/Crab_Chen_960.jpg"
}
"""
