//
//  Watson.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import Alamofire

class Watson {
    
    fileprivate static let API_HOST = "https://mna-guide.mybluemix.net/v1"
    
    // Function to get AUDIO from text
    static func speak(_ text: String, workspace id: String, completion: @escaping (Data?) -> Void) -> Alamofire.Request {
        let request = Alamofire.request(API_HOST + "/talk", method: .post, parameters: ["text": text, "workspace_id": id], encoding: JSONEncoding.default, headers: nil)
        
        request.response { (response) in
            if var data = response.data {
                self.repairWAVHeader(&data)
                completion(data)
            } else {
                completion(nil)
            }
        }
        
        return request
    }
    
    // Function to get TEXT answer
    static func answer(_ question: String, workspace id: String, completion: @escaping (String?) -> Void) -> Alamofire.Request {
        let request = Alamofire.request(API_HOST + "/answer", method: .post, parameters: ["question": question, "workspace_id": id], encoding: JSONEncoding.default, headers: nil)
        
        request.responseJSON { (response) in
            if let json = response.result.value as? [String: String] {
                completion(json["answer"])
            } else {
                completion(nil)
            }
        }
        
        return request
    }
    
    // Functino to get AUDIO aswer from question
    static func answerAndSpeech(question text: String, workspaceId: String, completion: @escaping (Data?) -> Void) -> Alamofire.Request {
        let request = Alamofire.request(API_HOST, method: .post, parameters: ["question": text, "workspace_id": workspaceId], encoding: JSONEncoding.default, headers: nil)
            
        request.response { (response) in
                if var data = response.data {
                    self.repairWAVHeader(&data)
                    completion(data)
                } else {
                    completion(nil)
                }
        }
        
        return request
    }
    
    // Three functions from WDC to repair WAV header:
    static func repairWAVHeader(_ data: inout Data) {
        
        // resources for WAV header format:
        // [1] http://unusedino.de/ec64/technical/formats/wav.html
        // [2] http://soundfile.sapp.org/doc/WaveFormat/
        
        // update RIFF chunk size
        let fileLength = data.count
        
        // César Guadarrama Fix
        if (fileLength < 8) {
            return
        }
        
        var riffChunkSize = UInt32(fileLength - 8)
        let riffChunkSizeData = Data(bytes: &riffChunkSize, count: MemoryLayout<UInt32>.stride)
        data.replaceSubrange(Range(uncheckedBounds: (lower: 4, upper: 8)), with: riffChunkSizeData)
        
        // Find data subchunk
        var subchunkID: String?
        var subchunkSize = 0
        var fieldOffset = 12
        let fieldSize = 4
        while true {
            // prevent running off the end of the byte buffer
            if fieldOffset + 2*fieldSize >= data.count {
                return
            }
            
            // read subchunk ID
            subchunkID = dataToUTF8String(data, offset: fieldOffset, length: fieldSize)
            fieldOffset += fieldSize
            if subchunkID == "data" {
                break
            }
            
            // read subchunk size
            subchunkSize = dataToUInt32(data, offset: fieldOffset)
            fieldOffset += fieldSize + subchunkSize
        }
        
        // compute data subchunk size (excludes id and size fields)
        var dataSubchunkSize = UInt32(data.count - fieldOffset - fieldSize)
        
        // update data subchunk size
        let dataSubchunkSizeData = Data(bytes: &dataSubchunkSize, count: MemoryLayout<UInt32>.stride)
        data.replaceSubrange(Range(uncheckedBounds: (lower: fieldOffset, upper: fieldOffset+fieldSize)), with: dataSubchunkSizeData)
    }
    
    static func dataToUTF8String(_ data: Data, offset: Int, length: Int) -> String? {
        let range = Range(uncheckedBounds: (lower: offset, upper: offset + length))
        let subdata = data.subdata(in: range)
        return String(data: subdata, encoding: String.Encoding.utf8)
    }
    
    static func dataToUInt32(_ data: Data, offset: Int) -> Int {
        var num: UInt8 = 0
        let length = 4
        let range = Range(uncheckedBounds: (lower: offset, upper: offset + length))
        data.copyBytes(to: &num, from: range)
        return Int(num)
    }
}
