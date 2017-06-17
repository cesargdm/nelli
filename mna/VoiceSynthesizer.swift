//
//  VoiceSynthesizer.swift
//  Watson Conversation
//
//  Created by Marco Aurélio Bigélli Cardoso on 20/01/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire
import AudioToolbox

class VoiceSynthesizer: NSObject {
    // Delegate to receive callbacks:
    weak var delegate: VoiceSynthesizerDelegate?
    
    // Reference to audio player
    private var player: AVAudioPlayer?
    
    private var cacheOn = true
    private let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    var cancelled = false
    var currentRequest: DataRequest?
    
    private let problemWords: [String : String] = [
        "mestiço": "mêstiço",
        "wright": "urait",
        "nemirovsky": "nemiróvsky",
        "ibm": "i b m",
        "pinacoteca": "pi nacoteca",
        "talkative art": "talkative arte",
        "chegue": "chêgue"
    ]
    
    private var synthQueue = [String]()
    
    // Gets audio data for text. Tries cache first, and adds to cache if that fails
    func synthesize(text: String) {
        delegate?.didStartSynthesizing()
        if text == "" {
            delegate?.didStopSynthesizing(audio: nil)
            return
        }
        
        let processedText = prepareForSynthesis(text)
        
        if let data = dataFromCache(message: processedText) {
            delegate?.didStopSynthesizing(audio: data)
            return
        }
        
        actuallySynthesize(processedText, completion: { data in
            self.delegate?.didStopSynthesizing(audio: data)
        })
    }
    
    // Stops download or audio playback immediately. Calls didStopSynthesizing or didStopReading accordingly.
    func cancel() {
        cancelled = true
        cacheOn = false
        currentRequest?.cancel()
        delegate?.didStopSynthesizing(audio: nil)
    }
    
    // Synthesizes a bunch of messages and saves to cache
    func massSynthesize(texts: [String]) {
        delegate?.didStartSynthesizing()
        
        var msgCount = 0
        for text in texts {
            textToData(text, completion: { _ in
                msgCount += 1
                if msgCount == texts.count {
                    self.delegate?.didFinishMassSynthesize()
                }
            })
        }
    }
    
    // Same as synthesize but with closure
    private func textToData(_ text: String, completion: @escaping (Data?) -> (Void)) {
        if text == "" {
            completion(nil)
            return
        }
        
        let processedText = prepareForSynthesis(text)
        
        if let data = dataFromCache(message: processedText) {
            completion(data)
            return
        }
        
        actuallySynthesize(processedText, completion: { data in
            completion(data)
        })

    }
    
    // Activate Watson Text-to-Speech API for audio synthesis
    private func actuallySynthesize(_ text: String, completion: @escaping (Data?) -> (Void)) {
        let requestURL = "https://talkative-art-collector.mybluemix.net/api/v1/audios/synthesize"
        let requestParams = ["text": text]
        currentRequest = request(requestURL, method: .post, parameters: requestParams, encoding: JSONEncoding.default).response {
            response in
//            print(response)
            if response.response?.statusCode == 200 {
                if let audio = response.data {
                    var wav = audio
                    self.repairWAVHeader(data: &wav)
                    if self.cacheOn {
                        self.dataToCache(message: text, data: wav)
                    }
                    completion(wav)
                } else {
                    completion(nil)
                }

                // Turn cache back on (if this callback was from cancelling a download)
                self.cacheOn = true
            } else {
                completion(nil)
            }
            
            
        }

    }
    
    // Processes text for text-to-speech. Lowercase and swap problem words
    private func prepareForSynthesis(_ text: String) -> String {
        var output = text.lowercased()
        for (problemWord, fixedWord) in problemWords {
            output = output.replacingOccurrences(of: problemWord, with: fixedWord)
        }
        return output
    }
    
    private func dataFromCache(message: String) -> Data? {
        let finalPath = self.documentsPath + String(message.hash) + ".wav"
        let input = FileHandle(forReadingAtPath: finalPath)
        if (input == nil) {
            return nil
        }
        let data = input?.readDataToEndOfFile()
        input?.closeFile()
        return data
    }
    
    private func dataToCache(message: String, data: Data) {
        let finalPath = self.documentsPath + String(message.hash) + ".wav"
        FileManager.default.createFile(atPath: finalPath, contents: data, attributes: nil)
        print("creating file at " + finalPath)

    }
    
    // Three functions from WDC to repair WAV header:
    func repairWAVHeader(data: inout Data) {
        
        // resources for WAV header format:
        // [1] http://unusedino.de/ec64/technical/formats/wav.html
        // [2] http://soundfile.sapp.org/doc/WaveFormat/
        
        // update RIFF chunk size
        let fileLength = data.count
        var riffChunkSize = UInt32(fileLength - 8)
        let riffChunkSizeData = Data(bytes: &riffChunkSize, count: MemoryLayout<UInt32>.stride)
        data.replaceSubrange(Range(uncheckedBounds: (lower: 4, upper: 8)), with: riffChunkSizeData)
        
        // find data subchunk
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
            subchunkID = dataToUTF8String(data: data, offset: fieldOffset, length: fieldSize)
            fieldOffset += fieldSize
            if subchunkID == "data" {
                break
            }
            
            // read subchunk size
            subchunkSize = dataToUInt32(data: data, offset: fieldOffset)
            fieldOffset += fieldSize + subchunkSize
        }
        
        // compute data subchunk size (excludes id and size fields)
        var dataSubchunkSize = UInt32(data.count - fieldOffset - fieldSize)
        
        // update data subchunk size
        let dataSubchunkSizeData = Data(bytes: &dataSubchunkSize, count: MemoryLayout<UInt32>.stride)
        data.replaceSubrange(Range(uncheckedBounds: (lower: fieldOffset, upper: fieldOffset+fieldSize)), with: dataSubchunkSizeData)
    }
    
    func dataToUTF8String(data: Data, offset: Int, length: Int) -> String? {
        let range = Range(uncheckedBounds: (lower: offset, upper: offset + length))
        let subdata = data.subdata(in: range)
        return String(data: subdata, encoding: String.Encoding.utf8)
    }
    
    func dataToUInt32(data: Data, offset: Int) -> Int {
        var num: UInt8 = 0
        let length = 4
        let range = Range(uncheckedBounds: (lower: offset, upper: offset + length))
        data.copyBytes(to: &num, from: range)
        return Int(num)
    }

}

protocol VoiceSynthesizerDelegate: class {
    func didStartSynthesizing()
    func didStopSynthesizing(audio: Data?)
    func didFinishMassSynthesize()
}
