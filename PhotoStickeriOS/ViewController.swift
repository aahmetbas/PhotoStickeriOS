//
//  ViewController.swift
//  PhotoSticker
//
//  Created by Alp on 22.12.2016.
//  Copyright © 2016 Alp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PhotoStickerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

    
    @IBAction func photSticker(_ sender: Any) {
        let myStoryboard = UIStoryboard(name: "PhotoSticker", bundle: nil)
        let photoSticker = myStoryboard.instantiateViewController(withIdentifier: "PhotoSticker") as! PhotoSticker
        photoSticker.delegate = self
        photoSticker.navBarTitle = "PhotoSticker"
        photoSticker.saveCameraRoll = false
        self.present(photoSticker, animated: true, completion: nil)
    }
    
    func getImage(image: UIImage) {
        imageView.image = image
    }
}

