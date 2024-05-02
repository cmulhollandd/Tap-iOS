//
//  NewPostViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/2/24.
//

import Foundation
import UIKit

class NewPostViewController: UIViewController {
    
    @IBOutlet var textView: UITextView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageViewHelper: UILabel!
    
    private var image: UIImage?
    var feedStore: FeedPostStore!
    
    private let textPrompts = [
        "Share your most embarrassing moment... if you dare!",
        "What's the funniest thing that happened to you this week?",
        "Describe the last dream you had... the weirder, the better!",
        "If you could have any superpower for a day, what would it be and why?",
        "What's the most ridiculous thing you've ever bought online?",
        "If you could swap lives with any celebrity for a day, who would it be and why?",
        "What's your favorite joke that always cracks you up?",
        "Share your best (or worst) pickup line!",
        "If you could create a new holiday, what would it be called and how would we celebrate it?",
        "What's your favorite meme of all time?",
        "What's the weirdest food combination you've ever tried?",
        "If you were a character in a sitcom, what would your catchphrase be?",
        "What's the most ridiculous thing you've done to avoid doing something else?",
        "What's the silliest thing you believed as a child?",
        "If you could have dinner with any fictional character, who would it be and why?",
        "What's your go-to karaoke song and why?",
        "What's the strangest talent you have?",
        "If you could time travel to any period in history, where would you go and why?",
        "What's the most embarrassing thing you've ever said in public?",
        "If you could only eat one food for the rest of your life, what would it be?",
        "Share the weirdest fact you know!",
        "What's the most ridiculous thing you've done while bored?",
        "If you could trade lives with any cartoon character, who would it be and why?",
        "What's the most ridiculous thing you've ever Googled?",
        "If you could have any animal as a pet, mythical or not, what would it be?",
        "What's the most embarrassing autocorrect fail you've had?",
        "If you could choose any actor to play you in a movie, who would it be?",
        "What's the silliest thing you've argued about with someone?",
        "What's the weirdest phobia you've heard of?",
        "If you could have a conversation with any historical figure, who would it be and why?",
        "Share the funniest text message you've ever received!",
        "What's the weirdest thing you've ever seen someone do in public?",
        "If you could have any job in the world for a day, what would it be and why?",
        "What's the most ridiculous excuse you've used to get out of something?",
        "If you could be any fictional character, who would it be and why?",
        "What's the most bizarre dream you've ever had?",
        "Share your favorite internet meme and explain why it's your favorite!",
        "If you could be a fly on the wall anywhere, where would you choose and why?",
        "What's the most embarrassing thing you've ever done for a crush?",
        "If you could invent a new flavor of ice cream, what would it be?",
        "What's the weirdest place you've ever fallen asleep?",
        "If you could have any mythical creature as a pet, what would it be and why?",
        "Share the most ridiculous thing you've ever done in the name of procrastination!",
        "If you could visit any planet in the solar system, which would you choose and why?",
        "What's the silliest nickname you've ever had?",
        "If you could be a character in any TV show, which show would you choose?",
        "What's the most ridiculous rumor you've ever heard about yourself?",
        "If you could create a new flavor of potato chip, what would it be?",
        "What's the weirdest thing you've ever found at the bottom of your bag?",
        "If you could have any fictional character as your best friend, who would it be and why?",
        "What's the most absurd thing you've ever done on a dare?",
        "If you could have any animal ability, what would it be and why?",
        "What's the strangest thing you've ever eaten just to try it?",
        "If you could be any age for a week, what age would you choose and why?"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        textView.text = textPrompts.randomElement()
        textView.textColor = .lightGray
        textView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let image = image {
            self.imageView.image = image
            self.imageViewHelper.text = "Tap image to remove"
        } else {
            self.imageView.image = UIImage(systemName: "photo.badge.plus")
            self.imageViewHelper.text = "Tap photo icon to add an image"
        }
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
     
        let user = (UIApplication.shared.delegate as! AppDelegate).user!
        
        let text = textView.text!
        
        var hasImage = false
        if let _ = image {
            hasImage = true
        }
        
        let newPost = TapFeedPost(postingUserUsername: user.username, postingUserProfileImage: user.profilePhoto, hasImage: hasImage, textContent: text, imageContent: image, postDate: Date())
        
        feedStore.newPost(newPost)
        
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true)
    }
    
    @IBAction func backgroundTapRecognized(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {
        self.textView.endEditing(true)
        
        if let _ = image {
            self.image = nil
            self.imageView.image = UIImage(systemName: "photo.badge.plus")
            return
        }
        print("Picking or Taking photo")
        
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .camera
        self.present(controller, animated: true)
    }
}


extension NewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.image = nil
        self.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.image = image
        } else if let image = info[.originalImage] as? UIImage {
            self.image = image
        }
        
        dismiss(animated: true)
    }
}

extension NewPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = textPrompts.randomElement()
            textView.textColor = UIColor.lightGray
        }
    }
}
