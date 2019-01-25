//
//  Flood.swift
//  FloodWarning
//
//  Created by Romel Levy on 1/24/19.
//  Copyright © 2019 Romel. All rights reserved.
//

import Foundation

struct Flood{
    
    var latitude :Double
    var longitude :Double
    
    func toDictionary() -> [String:Any]{
        
        return ["latitude":self.latitude,"longiitude":self.longitude]
    }
}

extension Flood {
    
    init?(dictionary :[String:Any]) {
    
        guard let latitude = dictionary["latitude"] as? Double, let longitude = dictionary["longitude"] as? Double else {
            
            return nil
        }
        
        self.latitude = latitude
        self.longitude = longitude
    }
}
