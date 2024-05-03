//
//  FountainReview.swift
//  Tap-iOS
//
//  Created by Charlie Mulholland on 4/16/24.
//

import Foundation

class FountainReview: Codable {
    private var rating: Double
    private var description: String
    
    
    init(rating: Double, description: String) {
        self.rating = rating
        self.description = description
    }
    
    func getDescription() -> String {
        return description
    }
    
    func getRating() -> Double {
        return rating
    }
    
    func getRatingString() -> String {
        let nf = NumberFormatter()
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        
        return nf.string(from: rating as NSNumber)!
    }
}
