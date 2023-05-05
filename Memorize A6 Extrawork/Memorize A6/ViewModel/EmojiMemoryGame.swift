//
//  EmojiMemoryGame.swift
//  Memorize A6
//
//  Created by Lukas Hering on 03.05.23.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {
    typealias Card = MemoryGame<String>.Card
    @Published private var model: MemoryGame<String>
    let chosenTheme: Theme
    
// start a new MemoryGame
    static func createMemoryGame(of theme: Theme) -> MemoryGame<String> {
        let emojis = theme.emojis.map { String($0) }.shuffled()
        
        return MemoryGame(numberOfPairsOfCards: theme.numberOfPairsOfCards) { Index in
            emojis[Index]
        }
    }
    
    init(theme: Theme) {
        chosenTheme = theme
        model = EmojiMemoryGame.createMemoryGame(of: chosenTheme)
    }
    
    
    var score: Int { return model.score }
    
    
    var cards: [Card] { return model.cards }
    
//check if the game has ended
    private(set) var isEndOfGame = false
    var foundPairsCount: Int { return model.foundPairsCount }
    
    func checkIfEndOfGame() {
        if model.foundPairsCount == chosenTheme.numberOfPairsOfCards {
            isEndOfGame = true
        }
        else {
            isEndOfGame = false
        }
    }
    
// function for choosing a card
    func choose(_ card: Card) {
        model.choose(card)
        checkIfEndOfGame()
    }
    
// function for starting a new Game
    func restart() {
        model = EmojiMemoryGame.createMemoryGame(of: chosenTheme)
        checkIfEndOfGame()
    }
}
