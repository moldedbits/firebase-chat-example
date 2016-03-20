//
//  Response.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 20/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONImport {
    func fromJson(json:JSON)
}

class Response<T> : NSObject {
    var data:[T]?
}

extension Response {
    
}