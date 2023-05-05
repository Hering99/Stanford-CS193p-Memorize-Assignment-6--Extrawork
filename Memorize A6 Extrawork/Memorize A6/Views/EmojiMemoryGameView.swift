//
//  EmojiMemoryGameView.swift
//  Memorize A6
//
//  Created by Lukas Hering on 03.05.23.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var game: EmojiMemoryGame
    
    // Design of the Memorygame
    var body: some View {
        VStack {
            Text("Score: \(game.score)")
            if game.isEndOfGame == true {
                withAnimation(.easeInOut(duration: 2.5).delay(1.5)) {
                    Text("Good Game").foregroundColor(Color(rgbaColor: game.chosenTheme.color)).font(.largeTitle)
                }
            }
            else {
                gameBody
                    .foregroundColor(Color(rgbaColor: game.chosenTheme.color))
                }
        }
        .padding(.horizontal)
        .navigationTitle("\(game.chosenTheme.name)!")
        .toolbar {
            newGameButton
        }
    }
    
    @State private var dealt = Set<Int>()
    
    @Namespace private var dealingNamespace
    
    private func deal(_ card: MemoryGame<String>.Card) {
        dealt.insert(card.id)
    }
    
    private func isUndealt(_ card: MemoryGame<String>.Card) -> Bool {
        !dealt.contains(card.id)
    }
    
    private func zIndex(of card: MemoryGame<String>.Card) -> Double {
        -Double(game.cards.firstIndex(where: { $0.id == card.id }) ?? 0)
    }
    
    var gameBody: some View {
        AspectVGrid(items: game.cards, aspectRatio: 2/3) {  card in
            if card.isMatched && !card.isFaceUp {
                Color.clear  // in some contexts, Color behaves like a View of a rectangle of that color
            }
            else {
                CardView(card: card)
                    .matchedGeometryEffect(id: card.id, in: dealingNamespace)
                    .padding(4)
                    .transition(AnyTransition.asymmetric(insertion: .identity, removal: .scale))
                    .zIndex(zIndex(of: card))
                    .onTapGesture {
                        withAnimation {
                            game.choose(card)
                        }
                    }
            }
        }
        .foregroundColor(Color(rgbaColor: game.chosenTheme.color))
    }
    
    
    
    var newGameButton: some View {
        Button("New Game") {
            withAnimation {
                dealt = []
                game.restart()
            }
        }
    }
    
    private struct CardConstants {
        static let color = Color.red
        static let aspectRatio: CGFloat = 2/3
        static let dealDuration: Double = 0.5
        static let totalDealDuration: Double = 2
        static let undealtHeight: CGFloat = 90
        static let undealtWidth: CGFloat =  undealtHeight * aspectRatio
    }

}


// single Carddesign
struct CardView: View {
    let card: MemoryGame<String>.Card
    
    @State private var animatedBonusRemaining: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if card.isConsumingBonusTime {
                        Pie(startAngle: Angle(degrees: 0 - 90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                            .onAppear() {
                                animatedBonusRemaining = card.bonusRemaining
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                    } else {
                        Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-card.bonusRemaining)*360-90))
                    }
                }
                .padding(5)
                .opacity(0.5)
                
                Text(card.content)
                    .padding(DrawingConstants.circlePadding)
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(Animation.linear(duration: 1))
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
            }
            .cardify(isFaceUp: card.isFaceUp)
        }
    }
    
    private func scale(thatFits size: CGSize) -> CGFloat {
        min(size.width, size.height) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.7
        static let fontSize: CGFloat = 32
        static let circlePadding: CGFloat = 5
    }
}
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        //let  game = EmojiMemoryGame(theme: ThemeStore(named: "default").themes[0])
        EmojiMemoryGameView(game: EmojiMemoryGame(theme: ThemeStore(named: "default").themes[0]))
            .preferredColorScheme(.dark)
        EmojiMemoryGameView(game: EmojiMemoryGame(theme: ThemeStore(named: "default").themes[0]))
            .preferredColorScheme(.light)
    }
}
