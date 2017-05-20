/*********************
 
 COMP 2601 Assignment 4
 Submitted by Ian Smith #100910972
 2016-04-06
 
 *********************/

//
//  TicTacToeGame.swift
//  COMP2601_A4
//
//  Created by Ian Smith on 2016-03-30.
//  Copyright © 2016 2601. All rights reserved.
//

import Foundation

/********
Class TicTacToe game
This is the UI-agnostic class to hold the game model and perform game-specific functions, such as "X plays on square 3".
The game AI is also housed here.
//Disclosure: the class started with code created for and old COMP1406 tutorial
//I have made many changes and consider it to be new
 *********/
public class TicTacToeGame{
    
    //This is the data structure that represents the game board
    //Notice the game board is represented in the model by a simple 1D array
    // the squares are:
    // 1 | 2 | 3
    // ---------
    // 4 | 5 | 6
    // ---------
    // 7 | 8 | 9
    //position 0 in the array is NOT USED
    var positions: [String] = ["*", " ", " ", " ", " ", " ", " ", " ", " ", " "];
    
    init(){
        initGame();
    }
    
    //board positions
    func initGame(){
        positions = ["*", " ", " ", " ", " ", " ", " ", " ", " ", " "];
    }

    //Answer whether string anXorO is in a winning position
    //String anXorO is expected to be either an "X" or an "O"
    func hasWon(anXorO: String) ->BoardLine{
        
        var finishLine = BoardLine();
        
        //check the rows for XXX or OOO
        if (positions[1] == anXorO && positions[2] == anXorO && positions[3] == anXorO ) {
            finishLine.start = 1;
            finishLine.end = 3;
        }
        else if (positions[4] == anXorO && positions[5] == anXorO && positions[6] == anXorO) {
            finishLine.start = 4;
            finishLine.end = 6;
        }
        else if (positions[7] == anXorO && positions[8] == anXorO && positions[9] == anXorO) {
            finishLine.start = 7;
            finishLine.end = 9;
        }
            
            //check the columns for XXX or OOO
        else if (positions[1] == anXorO && positions[4] == anXorO && positions[7] == anXorO) {
            finishLine.start = 1;
            finishLine.end = 7;
        }
        else if (positions[2] == anXorO && positions[5] == anXorO && positions[8] == anXorO) {
            finishLine.start = 2;
            finishLine.end = 8;
        }
        else if (positions[3] == anXorO && positions[6] == anXorO && positions[9] == anXorO) {
            finishLine.start = 3;
            finishLine.end = 9;
        }
            
            //check the diagonals for XXX or OOO
        else if(positions[1] == anXorO && positions[5] == anXorO && positions[9] == anXorO) {
            finishLine.start = 1;
            finishLine.end = 9;
        }
        else if(positions[3] == anXorO && positions[5] == anXorO && positions[7] == anXorO) {
            finishLine.start = 3;
            finishLine.end = 7;
        }
        
        return finishLine;
    }


    //Answer whether there are still free places to play on
    func hasFreePositions() -> Bool{
        return(numberOfFreePositions() != 0);
    }

    //Answer the number of free places left to play on
    func numberOfFreePositions() -> Int{
        var numberFree: Int = 0;
        for i in 1...positions.count{
            if(isFree(i)) {numberFree += 1;}
        }
        return numberFree;
    }
    
    //Answer whether position aPosition is free to play on
    //It is not free if there is an "X" or "O" on it
    func isFree(aPosition : Int) -> Bool {
  
        if( aPosition < 1 || aPosition > 9) {return false;}
        return !((positions[aPosition] == "X") || (positions[aPosition] == "O"));
    }
    
  
    //Make a move for player X
    //Mark position aPosition with an X if it's free
    //if the position is not free return false indicating the move did not succeed
    func XPlays(aPosition : Int) -> Bool{    
        if(isFree(aPosition)){
            positions[aPosition] = "X";
            return true;
        }
        return false;
    }
    
    //Make a move for player O
    //Mark position aPosition with an "O" if it's free
    //if the position is not free return false indicating the move did not succeed
    func OPlays(aPosition : Int) -> Bool{
        if(isFree(aPosition)){
            positions[aPosition] = "O";
            return true;
        }
        return false;
    }
 
    //The function returns the index of the first square that X can win on
    func findXWin() -> Int {
        // rows
        if( positions[1] == "X" && positions[2] == "X" && isFree(3)) {return 3;}
        if( positions[2] == "X" && positions[3] == "X" && isFree(1)) {return 1;}
        if( positions[1] == "X" && positions[3] == "X" && isFree(2)) {return 2;}
        
        if( positions[4] == "X" && positions[5] == "X" && isFree(6)) {return 6;}
        if( positions[4] == "X" && positions[6] == "X" && isFree(5)) {return 5;}
        if( positions[5] == "X" && positions[6] == "X" && isFree(4)) {return 4;}
        
        if( positions[7] == "X" && positions[8] == "X" && isFree(9)) {return 9;}
        if( positions[7] == "X" && positions[9] == "X" && isFree(8)) {return 8;}
        if( positions[8] == "X" && positions[9] == "X" && isFree(7)) {return 7;}
        
        // columns
        if(positions[1] == "X" && positions[4] == "X" && isFree(7)) {return 7;}
        if(positions[1] == "X" && positions[7] == "X" && isFree(4)) {return 4;}
        if(positions[4] == "X" && positions[7] == "X" && isFree(1)) {return 1;}
        
        if(positions[2] == "X" && positions[5] == "X" && isFree(8)) {return 8;}
        if(positions[5] == "X" && positions[8] == "X" && isFree(2)) {return 2;}
        if(positions[2] == "X" && positions[8] == "X" && isFree(5)) {return 5;}
        
        if(positions[3] == "X" && positions[6] == "X" && isFree(9)) {return 9;}
        if(positions[3] == "X" && positions[9] == "X" && isFree(6)) {return 6;}
        if(positions[6] == "X" && positions[9] == "X" && isFree(3)) {return 3;}
        
        // diagonals
        
        if(positions[1] == "X" && positions[5] == "X" && isFree(9)) {return 9;}
        if(positions[1] == "X" && positions[9] == "X" && isFree(5)) {return 5;}
        if(positions[5] == "X" && positions[9] == "X" && isFree(1)) {return 1;}
        
        if(positions[3] == "X" && positions[5] == "X" && isFree(7)) {return 7;}
        if(positions[3] == "X" && positions[7] == "X" && isFree(5)) {return 5;}
        if(positions[5] == "X" && positions[7] == "X" && isFree(3)) {return 3;}
        
        return 0;
    }
    
    //The function returns the index of the first square that O can win on
    func findOWin() -> Int {
        // rows
        if( positions[1] == "O" && positions[2] == "O" && isFree(3)) {return 3;}
        if( positions[2] == "O" && positions[3] == "O" && isFree(1)) {return 1;}
        if( positions[1] == "O" && positions[3] == "O" && isFree(2)) {return 2;}
        
        if( positions[4] == "O" && positions[5] == "O" && isFree(6)) {return 6;}
        if( positions[4] == "O" && positions[6] == "O" && isFree(5)) {return 5;}
        if( positions[5] == "O" && positions[6] == "O" && isFree(4)) {return 4;}
        
        if( positions[7] == "O" && positions[8] == "O" && isFree(9)) {return 9;}
        if( positions[7] == "O" && positions[9] == "O" && isFree(8)) {return 8;}
        if( positions[8] == "O" && positions[9] == "O" && isFree(7)) {return 7;}
        
        // columns
        if( positions[1] == "O" && positions[4] == "O" && isFree(7)) {return 7;}
        if( positions[1] == "O" && positions[7] == "O" && isFree(4)) {return 4;}
        if( positions[4] == "O" && positions[7] == "O" && isFree(1)) {return 1;}
        
        if( positions[2] == "O" && positions[5] == "O" && isFree(8)) {return 8;}
        if( positions[5] == "O" && positions[8] == "O" && isFree(2)) {return 2;}
        if( positions[2] == "O" && positions[8] == "O" && isFree(5)) {return 5;}
        
        if( positions[3] == "O" && positions[6] == "O" && isFree(9)) {return 9;}
        if( positions[3] == "O" && positions[9] == "O" && isFree(6)) {return 6;}
        if( positions[6] == "O" && positions[9] == "O" && isFree(3)) {return 3;}
        
        // diagonals
        
        if( positions[1] == "O" && positions[5] == "O" && isFree(9)) {return 9;}
        if( positions[1] == "O" && positions[9] == "O" && isFree(5)) {return 5;}
        if( positions[5] == "O" && positions[9] == "O" && isFree(1)) {return 1;}
        
        if( positions[3] == "O" && positions[5] == "O" && isFree(7)) {return 7;}
        if( positions[3] == "O" && positions[7] == "O" && isFree(5)) {return 5;}
        if( positions[5] == "O" && positions[7] == "O" && isFree(3)) {return 3;}
        
        return 0;
        
    }
    
    func freeCorner() -> Int {
        if(isFree(1)) {return 1;}
        if(isFree(3)) {return 3;}
        if(isFree(7)) {return 7;}
        if(isFree(9)) {return 9;}
        return 0;
    }
    
    func randomMove() -> Int{
        if(isFree(1)) {return 1;}
        else if(isFree(3)) {return (3);}
        else if(isFree(7)) {return (7);}
        else if(isFree(9)) {return(9);}
        else if(isFree(2)) {return(2);}
        else if(isFree(4)) {return(4);}
        else if(isFree(5)) {return(5);}
        else if(isFree(6)) {return(6);}
        
        return(8);
    }
 
    
    //Basic Strategy: play on first available free position that can be found
    //but prefer the corners when available
    func makeADefendingMove(player: String) -> Int{
        
        if(player == "X"){
            
            if findXWin() != 0{
                return findXWin();
            } else if findOWin() != 0{
                return findOWin();
            } else if isFree(5) {
                return 5;
            } else if freeCorner() != 0{
                return freeCorner();
            } else{
                return randomMove();
            }
            
        } else {
            
            if findOWin() != 0{
                return findOWin();
            } else if findXWin() != 0{
                return findXWin();
            } else if isFree(5) {
                return 5;
            } else if freeCorner() != 0{
                return freeCorner();
            } else{
                return randomMove();
            }
        }
    }
    
    //This method prints the game board on the console
    func printBoard(){
        print("" );
        print("" );
        print("   |   |   ");
        print(" \(positions[1]) | \(positions[2]) | \(positions[3])");
        print("   |   |   ");
        print("-----------");
        print("   |   |   ");
        print(" \(positions[4]) | \(positions[5]) | \(positions[6])");
        print("   |   |   ");
        print("-----------");
        print("   |   |   ");
        print(" \(positions[7]) | \(positions[8]) | \(positions[9])");
        print("   |   |   ");
    }
    
}

