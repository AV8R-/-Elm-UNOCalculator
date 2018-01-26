//
//  UNOCalculatorApp.swift
//  UNOCalculator
//
//  Created by Богдан Маншилин on 25/01/2018.
//  Copyright © 2018 BManshilin. All rights reserved.
//

import Foundation
import VirtualViews
import Elm

struct Player {
    let name: String
}

struct Round {
    let scores: [Int]
}

struct Game {
    var players: [Player] = []
    var rounds: [Round] = []
    var isPlaying: Bool = false
}

extension Array where Element == Player {
    var tableViewController: ViewController<Game.Message> {
        var cells: [TableViewCell<Game.Message>] = zip(self, self.indices).map { (el) in
            let (item, index) = el
            return TableViewCell(
                text: item.name,
                onSelect: .editPlayer(at: index),
                onDelete: .deletePlayer(at: index)
            )
        }
        
        cells.append(TableViewCell(text: "Add", onSelect: .addPlayer, onDelete: nil))
        
        return ViewController.tableViewController(TableView(items: cells))
    }
    
    func joined() -> String {
        guard count > 0 else {
            return ""
        }
        return self[1..<count].reduce(first!.name) { $0 + ", \($1.name)" }
    }
}

extension Array where Element == Round {
    func viewController(for players: [Player]) -> ViewController<Game.Message> {
        return ViewController.viewController(View.label(text: players.joined()))
    }
}

extension Game: RootComponent {
    enum Message {
        case newGame
        case addPlayer
        case createPlayer(String?)
        case editPlayer(at: Int)
        case deletePlayer(at: Int)
        case play
    }
    
    var viewController: ViewController<Message> {
        let addList: BarButtonItem<Message> = BarButtonItem.system(.play, action: .play)
        
        var viewControllers: [NavigationItem<Message>] = [
            NavigationItem(
                title: "Players",
                leftBarButtonItem: nil,
                rightBarButtonItems: [addList],
                viewController: players.tableViewController
            )
        ]
        
        if isPlaying {
            viewControllers.append(
                NavigationItem(
                    title: "Round \(rounds.count+1)",
                    rightBarButtonItems: [],
                    viewController: rounds.viewController(for: players)
                )
            )
        }

        return ViewController.navigationController(NavigationController(viewControllers: viewControllers, back: .newGame))
    }
    
    mutating func send(_ msg: Game.Message) -> [Command<Game.Message>] {
        switch msg {
        case .play:
            isPlaying = true
            return []
        case .newGame:
            isPlaying = false
            return []
        case .addPlayer:
            return [
                .modalTextAlert(title: "Add Player",
                                accept: "OK",
                                cancel: "Cancel",
                                placeholder: "Name",
                                convert: { .createPlayer($0) })
            ]
        case .createPlayer(let name?):
            players.append(Player(name: name))
            return []
        default:
            return []
        }
    }
    
    var subscriptions: [Subscription<Game.Message>] {
        return []
    }
    
}

extension Game.Message: Equatable {
    static func ==(lhs: Game.Message, rhs: Game.Message) -> Bool {
        return false
    }
}
