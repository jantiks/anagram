//
//  ViewController.swift
//  anagram
//
//  Created by Tigran on 11/27/20.
//  Copyright © 2020 Tigran. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Restart", style: .plain, target: self, action: #selector(startGame))
        
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsUrl){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }

    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
            
        }
        ac.addAction(submitAction)
        present(ac,animated: true)
    }

    // submits answer
    func submit(_ answer:String) {
        
        let alertTitle:String
        
        let lowerAnswer = answer.lowercased()
        if isPossible(word: lowerAnswer){
            if isOriginal(word: lowerAnswer){
                if isReal(word: lowerAnswer){
                    if isNotSame(word: lowerAnswer){
                        usedWords.insert(lowerAnswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                        
                    }else {
                        alertTitle = "It is same word as the title word"
                        showAlert(alertTitle)
                    }
                    
                }
                else {
                    alertTitle = "Word not recognized"
                    showAlert(alertTitle)
                }
            }else {
                alertTitle = "You used this word"
                showAlert(alertTitle)
            }
        }else {
            alertTitle = "The word is not possible"
            showAlert(alertTitle)
            
        }
        
    }
    
    func showAlert( _ title:String){
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
               ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(ac,animated: true)
    }
    
    // cheks if the word is possible
    func isPossible(word:String) -> Bool {
        var tempWord = title?.lowercased()
        
        for letter in word {
            if let position = tempWord?.firstIndex(of: letter){
                tempWord?.remove(at: position)
            }else {
                return false
            }
        }
        return true
    }
    
    //cheks is the word used yet
    func isOriginal(word:String) -> Bool {
        return !usedWords.contains(word)
    }
    
    //cheks is the world real english word
    func isReal(word:String) -> Bool {
        if word.count < 4 {
            return false
        }else {
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspeledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
            return misspeledRange.location == NSNotFound
        }
        
       
    }
    //cheks whether user word is the same as title word
    func isNotSame(word:String) -> Bool{
        return !(word == title?.lowercased())
    }
}

