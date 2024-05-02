//
//  PostDetailViewController.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/18/24.
//

import Foundation
import UIKit

class PostDetailViewController: UIViewController {
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var commentsTable: UITableView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dislikeButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    var barButtonItem: UIBarButtonItem!

    var post: TapFeedPost!
    var user: TapUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        guard let user = (UIApplication.shared.delegate as! AppDelegate).user else {
            return
        }
        
        if post.postingUserUsername == user.username {
            deleteButton.isEnabled = true
        } else {
            deleteButton.isEnabled = false
        }
        
        barButtonItem = UIBarButtonItem(title: "View Profile", style: .plain, target: self, action: #selector(presentUserVC))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationItem.title = "Post From \(user.username)"
        
        self.contentTextView.text = post.textContent
        
        commentsTable.dataSource = self
    }
    
    @objc func presentUserVC() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        if (self.likeButton.currentImage == UIImage(systemName: "hand.thumbsup")) {
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else {
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
    }
    
    @IBAction func dislikeButtonPressed(_ sender: UIButton) {
        if (self.dislikeButton.currentImage == UIImage(systemName: "hand.thumbsdown")) {
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown.fill"), for: .normal)
        } else {
            self.dislikeButton.imageView!.image = UIImage(systemName: "hand.thumbsdown")
            self.dislikeButton.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
//        let commentController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .alert)
//        commentController.addTextField { textField in
//            textField.placeholder = "What Would You Like To Say?"
//        }
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
//        let submit = UIAlertAction(title: "Done", style: .default) {
//            action -> Void in
//            
//            guard let textField = commentController.textFields?[0] else {
//                return
//            }
//            let text = textField.text!
//            if (text.isEmpty) {
//                return
//            }
//            let user = (UIApplication.shared.delegate as! AppDelegate).user!
//            let newComment = TapFeedPost.TapComment(author: user.username, content: text)
//            self.post.comments.append(newComment)
//            self.commentsTable.reloadData()
//        }
//        commentController.addAction(submit)
//        commentController.addAction(cancel)
//        self.present(commentController, animated: true)
        let alert = UIAlertController(title: "Delete Post?", message: "This action cannot be undone", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            guard 
                let post = self.post,
                let user = (UIApplication.shared.delegate as! AppDelegate).user
            else {
                return
            }
            SocialAPI.deletePost(post, requester: user.username) { resp in
                if let _ = resp["error"] as? Bool {
                    // error occured
                    print(resp["message"])
                    return
                }
                // Worked
                if let nav = self.navigationController {
                    nav.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }
        }))
        present(alert, animated: true)
    }
}

extension PostDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.authorLabel.text = post.comments[indexPath.row].author
        cell.contentLabel.text = post.comments[indexPath.row].content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if self.post.comments.count == 0 {
            return "No Comments Here..."
        }
        return nil
    }
}
