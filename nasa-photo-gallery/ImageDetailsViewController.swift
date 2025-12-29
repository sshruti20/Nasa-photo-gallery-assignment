//
//  ImageViewController.swift
//  nasa-photo-gallery
//
//  Created by Shruti S on 29/12/25.
//



import UIKit

class ImageDetailsViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var imageUrlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailImageView.enableZoom()
        
        if imageUrlString != "" {
            self.detailImageView.load(url: URL(string: imageUrlString)!)
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if let img = self.detailImageView.image {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveCompleted), nil)
        }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                print("Save error: \(error.localizedDescription)")
            } else {
                print("Save finished!")
                let alert = UIAlertController(title: "Success", message: "Image Saved!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    
}


extension UIImageView {
  func enableZoom() {
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
    isUserInteractionEnabled = true
    addGestureRecognizer(pinchGesture)
  }

  @objc
  private func startZooming(_ sender: UIPinchGestureRecognizer) {
    let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
    guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
    sender.view?.transform = scale
    sender.scale = 1
  }
}

