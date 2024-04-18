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
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var commentsTable: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    var barButtonItem: UIBarButtonItem!
    
    var likeButton: UIBarButtonItem!
    var dislikeButton: UIBarButtonItem!
    var commentButton: UIBarButtonItem!
    
    var post: TapFeedPost!
    var user: TapUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let post = post else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        barButtonItem = UIBarButtonItem(title: "View Profile", style: .plain, target: self, action: #selector(presentUserVC))
        
        self.navigationItem.rightBarButtonItem = barButtonItem
        self.navigationItem.title = "Post From \(user.username)"
        
        self.contentTextView.text = post.textContent
        if let image = post.imageContent {
            self.contentImageView.image = image
        }
        
        commentsTable.dataSource = self
        
        self.likeButton = UIBarButtonItem(image: UIImage(systemName: "hand.thumbsup"), style: .plain, target: self, action: #selector(likeButtonPressed))
        self.likeButton.tintColor = UIColor(named: "PrimaryBlue")
        self.likeButton.width = self.toolBar.frame.width / 4
        self.dislikeButton  = UIBarButtonItem(image: UIImage(systemName: "hand.thumbsdown"), style: .plain, target: self, action: #selector(dislikeButtonPressed))
        self.dislikeButton.tintColor = UIColor(named: "PrimaryBlue")
        self.dislikeButton.width = self.toolBar.frame.width / 4
        self.commentButton = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(commentButtonPressed))
        self.commentButton.title = "Comment"
        self.commentButton.tintColor = UIColor(named: "PrimaryBlue")
        self.commentButton.width = self.toolBar.frame.width / 2
        
        self.setToolbarItems([self.likeButton, self.dislikeButton, UIBarButtonItem(systemItem: .flexibleSpace), self.commentButton], animated: false)
        self.toolBar.tintColor = UIColor(named: "PrimaryBlue")
    }
    
    @objc func presentUserVC() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        vc.user = user
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func likeButtonPressed() {
        if (self.likeButton.image == UIImage(systemName: "hand.thumbsup")) {
            self.dislikeButton.image = UIImage(systemName: "hand.thumbsdown")
            self.likeButton.image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            self.likeButton.image = UIImage(systemName: "hand.thumbsup")
        }
    }
    
    @objc func dislikeButtonPressed() {
        if (self.dislikeButton.image == UIImage(systemName: "hand.thumbsdown")) {
            self.likeButton.image = UIImage(systemName: "hand.thumbsup")
            self.dislikeButton.image = UIImage(systemName: "hand.thumbsdown.fill")
        } else {
            self.dislikeButton.image = UIImage(systemName: "hand.thumbsdown")
        }
    }
    
    @objc func commentButtonPressed() {
        let commentController = UIAlertController(title: "New Comment", message: nil, preferredStyle: .alert)
        commentController.addTextField { textField in
            textField.placeholder = "What Would You Like To Say?"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let submit = UIAlertAction(title: "Done", style: .default) {
            action -> Void in
            
            guard let textField = commentController.textFields?[0] else {
                return
            }
            let text = textField.text!
            if (text.isEmpty) {
                return
            }
            let user = (UIApplication.shared.delegate as! AppDelegate).user!
            let newComment = TapFeedPost.TapComment(author: user.username, content: text)
            self.post.comments.append(newComment)
            self.commentsTable.reloadData()
        }
        commentController.addAction(submit)
        commentController.addAction(cancel)
        self.present(commentController, animated: true)
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
