//
//  PhotoSticker.swift
//
//
//  Created by Alp on 8.12.2016.
//  Copyright © 2016 Alp. All rights reserved.
//

import UIKit
import AVFoundation

// protocol used for sending data back
protocol PhotoStickerDelegate: class {
    func getImage(image: UIImage)
}

class PhotoSticker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IQLabelViewDelegate, SwiftColorPickerDelegate, UIPopoverPresentationControllerDelegate {
    
    var imageView: UIImageView!
    var navigationBar = UINavigationBar()
    var toolBar = UIToolbar()
    var navBarTitle = "Title"
    var imagePickerController: UIImagePickerController!
    fileprivate var popoverController: UIPopoverPresentationController!
    var labelView:IQLabelView!
    var uniqelabel = false
    var saveCameraRoll = false
    
    weak var delegate: PhotoStickerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigationBar()
        showToolBar()
        addImageView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(uniqelabel == true){
            labelView.hideEditingHandles()
        }
    }
    
    private func addImageView(){
        imageView = UIImageView(frame: CGRect(x: 0, y: ((view.frame.size.height/2) - (view.frame.size.width/2)), width: view.frame.size.width, height:view.frame.size.width))
        imageView.contentMode = UIViewContentMode.scaleToFill
        imageView.backgroundColor = UIColor.gray
        self.view.addSubview(imageView)
    }
    
    private func showNavigationBar(){
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:64))
        navigationBar.backgroundColor = UIColor.white
        
        let navigationItem = UINavigationItem()
        navigationItem.title = navBarTitle
        
        let leftButton =  UIBarButtonItem(title: "Save", style:   .plain, target: self, action: #selector(savePhoto(sender:)))
        navigationItem.leftBarButtonItem = leftButton
        let rightButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel(sender:)))
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
    }
    
    private func showToolBar(){
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height - 44, width: view.frame.size.width, height:44))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true

        let cameraRoll = UIBarButtonItem(image: UIImage(named: "PhotoSticker.bundle/photo-album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pickImageFromCameraRoll(sender:)))
        
        let camera = UIBarButtonItem(image: UIImage(named: "PhotoSticker.bundle/camera.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pickImageFromCamera(sender:)))
        
        let message = UIBarButtonItem(title: "Add Message", style: UIBarButtonItemStyle.plain, target: self, action: #selector(addMessage(sender:)))
        
        let color = UIBarButtonItem(image: UIImage(named: "PhotoSticker.bundle/colorPicker.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(pickColor(sender:)))
        
        let empty = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([camera, spaceButton, cameraRoll, spaceButton, message, spaceButton, empty, spaceButton, color], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        self.view.addSubview(toolBar)
    }
    
    func pickImageFromCameraRoll(sender: UIBarButtonItem){
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.sourceType = .photoLibrary
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = true
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.popoverController = UIPopoverPresentationController(presentedViewController: self, presenting: self.imagePickerController)
        } else {
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
    }
    
    func pickImageFromCamera(sender: UIBarButtonItem){
        checkCamera()
    }
    
    func checkCamera(){
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .authorized: callCamera()
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }

    func callCamera(){
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.camera
        myPickerController.allowsEditing = true
        self.present(myPickerController, animated: true, completion: nil)
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                    DispatchQueue.main.async() {
                        self.checkCamera() } }
            }
            }
        )
        present(alert, animated: true, completion: nil)
    }

    
    func addMessage(sender: UIBarButtonItem){
        if(!uniqelabel){
            let labelFrame = CGRect(x: Int((view.frame.size.width/2)-80), y: Int((view.frame.size.height/2)-40), width: 160, height: 80)
            labelView = IQLabelView(frame: labelFrame)
            labelView.delegate = self
            labelView.showsContentShadow = false
            labelView.attributedPlaceholder = NSAttributedString(string: ("Write Your Message"), attributes: [NSForegroundColorAttributeName: UIColor.white])
            self.view!.addSubview(labelView)
            uniqelabel = true
        }
    }
    
    func pickColor(sender: UIBarButtonItem){
        if let popupVC = self.storyboard?.instantiateViewController(withIdentifier: "SwiftColorPickerViewController") as? SwiftColorPickerViewController {
            popupVC.delegate = self
            popupVC.modalPresentationStyle = UIModalPresentationStyle.popover
            popupVC.popoverPresentationController!.delegate = self
            popupVC.popoverPresentationController?.sourceView = self.view
            popupVC.popoverPresentationController?.sourceRect = CGRect(x: (view.frame.size.width - 5), y: (view.frame.size.height - 5), width: 0, height: 0)
            present(popupVC, animated: true, completion: nil)
        }
    }
    
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func savePhoto(sender: UINavigationItem){
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationBar.isHidden = true
        toolBar.isHidden = true
        if(uniqelabel == true){
            labelView.hideEditingHandles()
        }
        AudioServicesPlaySystemSound (1108)
       
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.isOpaque, 0.0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return
        }
        self.view.layer.render(in: ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let size = Double((img?.size.width)!)
        
        let imageToBeSaved:UIImage = cropToBounds(image: img!, width: size, height: size)
        if(saveCameraRoll){
            UIImageWriteToSavedPhotosAlbum(imageToBeSaved, nil, nil, nil);
        }
        self.delegate?.getImage(image: imageToBeSaved)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        
        let contextSize: CGSize = contextImage.size
        
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }

    
    func cancel(sender: UINavigationItem){
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.imageView.image = image
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.popoverController.dismissalTransitionDidEnd(true)
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    /* SwiftColorPickerDelegate function */
    func colorSelectionChanged(selectedColor color: UIColor) {
        if(uniqelabel == true){
            labelView.textColor = color
        }
    }
    
    /* IQLabelView Delegate */
    func labelViewDidClose(_ label: IQLabelView) {
        uniqelabel = false
    }
    
    func displayMyAlertMessage(userMessage: String){
        let alert = UIAlertController(title: "Message", message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok",style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}


