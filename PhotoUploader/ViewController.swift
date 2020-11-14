//
//  ViewController.swift
//  PhotoUploader
//
//  Created by Anthony Kim on 11/11/20.
//

import UIKit
import FirebaseStorage
// make sure to conform to uiimagepicker delegate
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    
    // reference to storage instance
    private let storage = Storage.storage().reference() // off of this instance you can call difference functions that firebase provides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        label.numberOfLines = 0
        label.textAlignment = .center
        imageView.contentMode = .scaleAspectFit
        
        //check if there is a value set for the key and user default, if there is, try to download the image
        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
              let url = URL(string: urlString) else{
            return
        }
        
        label.text = urlString
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            // we want to put in main thread
            DispatchQueue.main.async { // make sure UI is updated, as soon as we get response
//                let image = UIImage(data: data)
//                self.imageView.image = image
                self.imageView.image = UIImage(data: data)
            }
           
        })
        
        task.resume() //kick off to request to get started
        
    }
    
    // action in vc that calls once the user tap that button
    @IBAction func didTapButton() {
        let picker = UIImagePickerController() //present photo library picker
        picker.sourceType = .photoLibrary
        picker.delegate = self //error if we dont conform
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    // called when user finishes picking the photo we are going to grab photo from in here
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        // after we have selected image in here, we want to get bytes for the image, the data adamant
        guard let imageData = image.pngData() else{
            return
        }
        //reference look like
        /*
         /Desktop/file.png
         */
        
        //reason we know is png is because we are getting png data out of it
        // whenever you want to get download url for the data, you can pass in that path to get it
        storage.child("images/file.png").putData(imageData, metadata: nil, completion: { _, error in
            //validate error did not occur
            guard error == nil else{
                print("Failed to upload")
                return
            }
            
            self.storage.child("images/file.png").downloadURL(completion: { url, error in
                // we want to unwrap the URL and make sure the error didnt occur
                guard let url = url, error==nil else{
                    return
                }
                let urlString = url.absoluteString
                print("Download URL:  \(urlString)")
                //save download url to user default so we can use it later to download the latest image
                UserDefaults.standard.set(urlString, forKey: "url")
            })
            //if it did successfully upload, we want to grab the download url from what we have uploaded
            
        })
        
        // upload image data
        // get download url
        // save download url to userDefaults
    }

    //called when picker is canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }


}

