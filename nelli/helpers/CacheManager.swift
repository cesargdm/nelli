//
//  CacheManager.swift
//  nelli
//
//  Created by Isaac Secundino, Marco Aurélio Bigélli Cardoso on 7/24/17.
//  Copyright © 2017 Isaac Secundino, IBM. All rights reserved.
//

import Foundation

class CacheManager {
    
    fileprivate static let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    fileprivate static let AUDIO_REGISTERS = "AUDIO_REGISTERS"
    fileprivate static let A_DAY = 86400 as Double
    fileprivate static let MAX_TIME_UNUSED = CacheManager.A_DAY * 7
    
    fileprivate var registers: [String: Double] = [:]
    
    init() {
        let dictionary = UserDefaults.standard.object(forKey: CacheManager.AUDIO_REGISTERS)
        if dictionary == nil {
            UserDefaults.standard.set(registers, forKey: CacheManager.AUDIO_REGISTERS)
        } else {
            registers = dictionary as! [String : Double]
        }
    }
    
    /* Check if there is a file/answer that is not frequently used (defined by MAX_TIME_UNUSED).
     * This file and its register are deleted
     */
    
    open static func deleteExpiredFilesFromCache() {
        
        let dic = UserDefaults.standard.object(forKey: CacheManager.AUDIO_REGISTERS)
        if dic != nil {
            let currentDate = Date().timeIntervalSince1970
            let registers = dic as! [String : Double]
            
            for register in registers {
                let regDate = register.value
                if currentDate - regDate > CacheManager.MAX_TIME_UNUSED {
                    CacheManager.deleteAnswer(register.key)
                }
            }
        }
    }
    
    /* Delete data and register */
    
    open static func deleteAnswer(_ answerHash: String) {
        do {
            try deleteDataFromCache(answerHash)
            removeAnswerRegister(answerHash)
        }
        catch {
            print("The file of [" + answerHash + ".wav] couldn't be deleted")
        }
    }
    
    fileprivate static func removeAnswerRegister(_ fileName: String) {
        var dic = CacheManager.getRegisterDictionary()
        dic.removeValue(forKey: fileName)
        UserDefaults.standard.set(dic, forKey: CacheManager.AUDIO_REGISTERS)
    }
    
    fileprivate static func deleteDataFromCache(_ fileName: String) throws {
        
        let finalPath = CacheManager.documentsPath + fileName + ".wav"
        try FileManager.default.removeItem(atPath: finalPath)
        print("Deleted: " + finalPath)
    }
    
    /* Store data in cache and create a register for it */
    
    public func store(answer: String, data: Data) {
        updateAnswerRegister(message: answer)
        dataToCache(message: answer, data: data)
    }
    
    //  Created by Marco Aurélio Bigélli Cardoso on 20/01/17.
    //  Copyright © 2017 IBM. All rights reserved.
    private func dataToCache(message: String, data: Data) {
        
        let finalPath = CacheManager.documentsPath + String(message.hash) + ".wav"
        FileManager.default.createFile(atPath: finalPath, contents: data, attributes: nil)
        print("creating file at " + finalPath)
    }
    
    
    private func updateAnswerRegister(message: String) {
        let key = String(message.hash)
        let currentDate = Date().timeIntervalSince1970
        registers.updateValue(currentDate, forKey: key)
        UserDefaults.standard.set(registers, forKey: CacheManager.AUDIO_REGISTERS)
    }
    
    /* Obtain data and update register timestamp */
    
    public func getAnswer(answer: String) -> Data? {
        let audio = dataFromCache(message: answer)
        if audio != nil {
            updateAnswerRegister(message: answer)
            return audio
        } else {
            return nil
        }
    }
    
    //  Created by Marco Aurélio Bigélli Cardoso on 20/01/17.
    //  Copyright © 2017 IBM. All rights reserved.
    private func dataFromCache(message: String) -> Data? {
        
        let finalPath = CacheManager.documentsPath + String(message.hash) + ".wav"
        let input = FileHandle(forReadingAtPath: finalPath)
        
        if (input == nil) {
            return nil
        }
        
        let data = input?.readDataToEndOfFile()
        input?.closeFile()
        return data
    }
    
    /* General functions */
    
    private static func getRegisterDictionary() -> [String : Double] {
        let dic = UserDefaults.standard.object(forKey: CacheManager.AUDIO_REGISTERS)
        if dic != nil {
            let reg = dic as! [String : Double]
            return reg
        } else {
            return [:]
        }
    }
    
    public static func printRegisters () {
        print("Show registers")
        let dic = CacheManager.getRegisterDictionary()
        print(dic)
    }
    
    public static func printRegistersTime() {
        let dic = CacheManager.getRegisterDictionary()
        let currentDate = Date().timeIntervalSince1970
        
        if dic.count == 0 {
            return
        }
        
        print("Hash Value          | Time from last use")
        print("--------------------+-------------------")
        
        for reg in dic {
            let days = (currentDate - reg.value) / CacheManager.A_DAY
            var result = String(days) + " days"
            
            if days < 1 {
                let hours = days * 24
                result = String(hours) + " hours"
                
                if hours < 1 {
                    let minutes = hours * 60
                    result = String(minutes) + " minutes"
                }
            }
            print(reg.key + " | " + result)
        }
    }
}

