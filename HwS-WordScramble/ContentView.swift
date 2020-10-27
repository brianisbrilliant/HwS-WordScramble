//
//  ContentView.swift
//  HwS-WordScramble
//
//  Created by Brian Foster on 10/22/20.
//  Copyright © 2020 Brian Foster. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let people = ["Han", "Leia", "Luke", "Mara Jade"]
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0
    
    // for error alert prompts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isLongEnough(word: String) -> Bool {
        if word.count >= 4 {
            return true
        } else {
            return false
        }
    }
    
    // var body is it's own function, don't build this inside of there.
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences.
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        // throw errors if the given word is nonsense or already guessed.
        guard isOriginal(word: answer) else {
            wordError(title: "Word has been used already", message: "Be more original")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word is too short", message: "Have some self respect!")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word is not recognised", message: "That word doesn't fit into the original word.")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word is not real", message: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        // find start.txt in our bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // load it into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // split that string into an array of strings, with each element being one word.
                let allWords = startWords.components(separatedBy: "\n")
                
                // pick one word at randon to be assigned to rootWord.
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // if we are here everything has worked correctly
                return
            }
        }
        
        // added code, reset list, keep score.
        usedWords.removeAll()       // this doesn't clear the list.
        
        // if we are here then there was a problem. Crash the program lol.
        fatalError("Could not load start.txt from our bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    var body: some View {
        
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                
                List(usedWords, id: \.self) {
                    // look at this HStack that happens by default!
                    Text($0)
                    Spacer()
                    Image(systemName: "\($0.count).circle")
                }
                Spacer()
                Text("Score: \(score)")
                .font(.title)
                .fontWeight(.bold)
                    .multilineTextAlignment(.trailing)
                    .padding()
                
                
            }
        .navigationBarTitle(rootWord)
        .navigationBarItems(trailing:
            Button("New Word") {
                self.startGame()
            }
        )
        .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
            }
        }
        
        
//
//        let input = "a b c"
//        let letters = input.components(separatedBy: " ")
//        let letter = letters.randomElement()
//        let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        let word = "swift"
//        let checker = UITextChecker()
//
//        let range = NSRange(location: 0, length: word.utf16.count)
//        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
//
//        let allGood = misspelledRange.location == NSNotFound
//
//        if let fileURL = Bundle.main.url(forResource: "some-file", withExtension: "txt") {
//            // then we found the file in our bundle!
//            if let fileContents = try? String(contentsOf: fileURL){
//                // we have successfully loaded the file into a string.
//            }
//
//        }
//
//        return Text("Hello World")
//        List {
//            Section(header: Text("Section 1")) {
//                Text("Section 1-1")
//            }
//
//            ForEach(people, id: \.self) {
//                Text($0)
//            }
//        }
//    .listStyle(GroupedListStyle())      // makes it look like a form.
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
