//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 10/17/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import os.log

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var size: UITextField!
    @IBOutlet weak var ceilTextField: UITextField!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var location = CGPoint(x: 0, y: 0)
    
    var meal: Meal?
    
    var pickerOption = ["71x51", "54x40", "52x24", "35x43", "24x28"]
    
    var ceilpickerOption = ["8", "10", "12", "14", "16", "18", "20", "22"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        
        nameTextField.delegate = self
        ceilTextField.delegate = self
        
        //size.delegate = self
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.tag = 1
        size.inputView = pickerView
        
        let ceilpickerView = UIPickerView()
        ceilpickerView.delegate = self
        ceilpickerView.tag = 2
        ceilTextField.inputView = ceilpickerView
        ceilTextField.text = ceilpickerOption[1]
        
        // Set up views if editing an existing Meal.
        //get user name
        var uname = UIDevice.current.name
        let ap = uname.characters.index(of: "\'")!
        uname = String(uname.characters.prefix(upTo: ap))
        
        if let meal = meal {
            navigationItem.title = meal.name
            let dash = meal.name.characters.index(of: "-")
            //print("viewDidLoad dash: \(dash)")
            if (dash == nil) {
                nameTextField.text = meal.name + "-" + uname
            } else {
                nameTextField.text = meal.name
            }
            //print("viewDidLoad nameTextField.text: \(nameTextField.text)")
            
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            size.text = meal.size
            
        }
        
        photoImageView.bounds.size = (photoImageView.image?.size)!
        
        //scrollView.addSubview(photoImageView)
        //view.addSubview(scrollView)
        //print("viewDidLoad photoImageview.image.size: \(photoImageView.image?.size)")
        
        
        print("viewDidLoad photoImageView.frame.width: \(photoImageView.frame.width) height: \(photoImageView.frame.height) view h: \(view.frame.height) w: \(view.frame.width) scrollview.frame h: \(scrollView.frame.height) w: \(scrollView.frame.width)")
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }
    
    //MARK: PickerViewDelegate
    
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return pickerOption.count
        }
        return ceilpickerOption.count
    
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 1){
            return pickerOption[row]
        }
        return ceilpickerOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 1 ) {
            size.text = pickerOption[row]
            size.resignFirstResponder()
        } else if (pickerView.tag == 2){
            ceilTextField.text = ceilpickerOption[row]
            ceilTextField.resignFirstResponder()
        }
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        //navigationItem.title = textField.text
        navigationItem.title = nameTextField.text!
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //MARK: Test to see if we have artwork
        if ((photoImageView.frame.width > 1.0) && (photoImageView.frame.width > 1.0)){
             print("Existing Artwork")
            //we already have an artwork Image so we add it scaled to the subview we add NEW Artwork
            
        
            // Set photoImageView to display the selected image.
            //print("imagePickerController selectedImage.size: \(selectedImage.size)")
            //selectedImage.contentMode = UIViewContentModeScaleAspectFit
            //let imageView = UIImageView(image: selectedImage)
            let imageView = UIImageView(image: photoImageView.image)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            imageView.bounds.size = (photoImageView.image?.size)!
        
            //imageView.frame = CGRect(x: 186, y: 240, width: 100, height: 200)
            //imageView.center = photoImageView.center
            //let ap = uname.characters.index(of: "\'")!
            //uname = String(uname.characters.prefix(upTo: ap))
        
            //MARK: Scaling artwork to ceiling height
        
            var string: String = size.text!
            let start = string.characters.index(of: "x")
            //let end = string.characters.index(after: start!)
            //let x1 = string.characters.index(start!, offsetBy: -2)
            //let x2 = string.characters.index(start!, offsetBy: -1)
            let x3 = string.characters.index(start!, offsetBy: 1)
            //let x4 = string.characters.index(start!, offsetBy: 2)

            let artHeight = string.substring(from: x3)
            let artWidth = string.substring(to: start!)
            var artworkHeight = Float(artHeight)
            artworkHeight = artworkHeight! / 12
            var artworkWidth = Float(artWidth)
            artworkWidth = artworkWidth! / 12
            let aspectRatio = artworkWidth! / artworkHeight!
        
            //Check if artwork is rotated
            if((Int(artworkWidth!) > Int(artworkHeight!)) && ( Int((imageView.image?.size.width)!) < Int((imageView.image?.size.height)!))) {
            let wt = artworkHeight
            artworkHeight = artworkWidth
            artworkWidth = wt
        
            }
        
        print("imagePickerController  artWidth: \(artWidth) artHeight: \(artHeight)  height: \(artworkHeight) ")
         //imageView.addSubview(self.view)
        photoImageView.image = selectedImage
        photoImageView.bounds.size = (photoImageView.image?.size)!
        
        let ceilingHeight = Float(ceilTextField.text!)
        let ptft: Float = Float((photoImageView.image?.size.height)!) / ceilingHeight!
        let height1 = Float(ptft * artworkHeight!)
    
        //let width = Int(ptft * artworkWidth!)
        let width = Int(aspectRatio * height1)
        let height = Int(height1)
        
        imageView.frame = CGRect(x: 687, y: 1516, width: width, height: height)
        
        photoImageView.addSubview(imageView)
           
        print("imagePickerController photoImageview.image.size: \(photoImageView.image?.size) imageView.frame.size: \(imageView.frame.size)")
            
        }else {
            //This is ADD NEW ArtWork
            print("NewArtWork")
            photoImageView.image = selectedImage
            photoImageView.bounds.size = (photoImageView.image?.size)!
            
        }
        
        
        
        
       
        //print("imagePickerController photoImageView.center: \(photoImageView.center) photoImageView.subview[0].center: \(photoImageView.subviews[0].center)")
        
        //self.view.addSubview(imagieView)
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let size = self.size.text ?? ""
        
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating, size: size)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromCamera(_ sender: UIBarButtonItem) {
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let cimagePickerController = UIImagePickerController()
        
        // Only allow photos to be taken.
        //imagePickerController.sourceType = .photoLibrary
        cimagePickerController.sourceType = .camera
        cimagePickerController.allowsEditing = true
        cimagePickerController.showsCameraControls = true
        cimagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        // Make sure ViewController is notified when the user picks an image.
        cimagePickerController.delegate = self
        present(cimagePickerController, animated: true, completion: nil)    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.sourceType = .camera
        //imagePickerController.allowsEditing = true
        //imagePickerController.showsCameraControls = true
        //imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        //print("updateZoomScrollForSize Before scrollView.bounds.size: \(size) photoImageView.bounds.size: \(photoImageView.bounds.size)")
        
        let widthScale = size.width / photoImageView.bounds.width
        let heightScale = size.height / photoImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        
        scrollView.zoomScale = minScale
        //print("updateZoomScrollForSize After ScrollView.bounds.size: \(size) photoImageView.bounds.size: \(photoImageView.bounds.size) minScale: \(minScale)")
        //print("updateZoomScrollForSize After scrollView.bounds.size: \(size) photoImageView.frame.size: \(photoImageView.frame.size) minScale: \(minScale)")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 4
        //updateMinZoomScaleForSize(view.bounds.size)
        updateMinZoomScaleForSize(scrollView.bounds.size)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        
        //print("updateConstraintForSize before: scrollView.bounds.size: \(size) photoImageView.frame.size: \(photoImageView.frame.size)")
        let yOffset = max(0, (size.height - photoImageView.frame.height) / 2)
        //yOffset = 0
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - photoImageView.frame.width) / 2)
        
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        //print("updateConstraintForSize After TopConstraint: \(imageViewTopConstraint.constant) Bottom: \(imageViewBottomConstraint.constant) Lead: \(imageViewLeadingConstraint.constant) Trail: \(imageViewTrailingConstraint.constant)")
        
        
        view.layoutIfNeeded()
    }
    
    //Move Artwork Image
    @IBAction func moveArtWork(_ sender: UIPanGestureRecognizer) {
        if ((sender.state != UIGestureRecognizerState.ended) && (sender.state != UIGestureRecognizerState.failed) && (sender.view?.subviews.count != 0)) {
         
            //print("sender.view?.subviews.count: \(sender.view?.subviews.count)")
         
            //print("moveArtWork view.subviews[0].location: \(sender.location(in: sender.view?.subviews[0])) view.location: \(sender.location(in: sender.view)) superview.location \(sender.location(in: sender.view?.superview))")
            sender.view?.subviews[0].center = sender.location(in: sender.view)
        }
        
    }
    /* use moveArtWork
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     
     print("touchesBegin")
     let touch: UITouch! = touches.first! as UITouch
     location = touch.location(in: photoImageView)
     photoImageView.subviews[0].center = location
     
     }
     override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     print("touchesMoved")
     let touch: UITouch! = touches.first! as UITouch
     location = touch.location(in: photoImageView)
     photoImageView.subviews[0].center = location
     
     }
     */
    
}

extension MealViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        // 1
        return photoImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(scrollView.bounds.size)  // 4
    }
    
}

