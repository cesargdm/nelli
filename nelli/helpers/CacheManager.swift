//
//  CacheManager.swift
//  nelli
//
//  Created by IBM Studio on 7/24/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation

class CacheManager {
    
    private static let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    private static let AUDIO_REGISTERS = "AUDIO_REGISTERS"
    private static let A_DAY = 86400 as Double
    private static let MAX_TIME_UNUSED = CacheManager.A_DAY * 1
    
    private var registers: [String: Double] = [:]
    
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
    
    public static func deleteExpiredFilesFromCache() {
        
        let dic = UserDefaults.standard.object(forKey: CacheManager.AUDIO_REGISTERS)
        if dic != nil {
            let currentDate = Date().timeIntervalSince1970
            let registers = dic as! [String : Double]
            
            for register in registers {
                let regDate = register.value
                if currentDate - regDate > CacheManager.MAX_TIME_UNUSED {
                    CacheManager.deleteAnswer(answerHash: register.key)
                }
            }
        }
    }
    
    /* Delete data and register */
    
    public static func deleteAnswer(answerHash: String) {
        do {
            try deleteDataFromCache(fileName: answerHash)
            removeAnswerRegister(fileName: answerHash)
        }
        catch {
            print("The file of [" + answerHash + ".wav] couldn't be deleted")
        }
    }
    
    private static func removeAnswerRegister(fileName: String) {
        var dic = CacheManager.getRegisterDictionary()
        dic.removeValue(forKey: fileName)
        UserDefaults.standard.set(dic, forKey: CacheManager.AUDIO_REGISTERS)
    }
    
    private static func deleteDataFromCache(fileName: String) throws {
        
        let finalPath = CacheManager.documentsPath + fileName + ".wav"
        try FileManager.default.removeItem(atPath: finalPath)
        print("Deleted: " + finalPath)
    }
    
    /* Store data in cache and create a register for it */
    
    public func storeAnswer(answer: String, data: Data) {
        updateAnswerRegister(message: answer)
        dataToCache(message: answer, data: data)
    }
    
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

