//
//  ShareViewModel.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-06-19.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

/**
 * The View model for the sharing action, where a chain is exported as a CSV-file.
 */
class ShareViewModel {
    
    let excludedActivityTypes = [UIActivityType.addToReadingList]
    
    var chain: Chain?
    var shareMode = false
    var fileURL: URL?
    
    func shareChain(_ chain: Chain?) {
        shareMode = true
        self.chain = chain
    }
    
    func sharedFileURL() -> URL? {
        guard let chain = self.chain else {
            log.error("No chain to export!")
            return nil
        }

        let df = DateFormatter()
        df.timeStyle = DateFormatter.Style.none
        df.dateStyle = DateFormatter.Style.short

        var csvData = ""
        // add header
        csvData = csvData.appending("Marked dates\n")
        
        // add the marked dates for the chosen chain
        for date in chain.days {
            if let d = date.date {
                csvData = csvData.appending(df.string(from: d))
                csvData = csvData.appending("\n")
            }
        }
        
        let fileName = "export" // name of output file without the extension
        
        let docDir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        if let fileURL = docDir?.appendingPathComponent(fileName).appendingPathExtension("csv") {
            do {
                try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
                log.debug("CSV: \(csvData)")
            }
            catch let error as NSError {
                log.error("Failed to export csv to: \(fileURL) due to: " + error.localizedDescription)
            }
            
            self.fileURL = fileURL
            return fileURL
        }
        else {
            log.error("Failed to create csv export file")
            self.fileURL = nil
            return nil
        }
    }
    
    func completed() {
        shareMode = false
 
        // Do not remove the created csv file here because if we do that, the deletion will occur before
        // the application targeted for the share action gets a chance to read the file
    }
    
}
