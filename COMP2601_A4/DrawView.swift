/*********************
 
 COMP 2601 Assignment 4
 Submitted by Ian Smith #100910972
 2016-04-06
 
 *********************/

//
//  DrawView.swift
//  Ex18
//
//  Created by Ian Smith on 2016-03-20.
//  Copyright © 2016 2601. All rights reserved.
//

import Foundation
import UIKit

//This is the controller of the game app
//It contains logic that conencts IO from the IOS app
//to a tictactoe game object
class DrawView: UIView {
    
    //constants to make the UI look nicer
    let uiSymSize: Int = 20;
    let xOffset: Int = 50;
    let yOffset: Int = 100;
    
    //UI Settings
    let gridLineColor: UIColor = UIColor.blackColor();
    let currentLineColor: UIColor = UIColor.redColor();
    let drawingLineColor: UIColor = UIColor.redColor();
    let shapeColor: UIColor = UIColor.blueColor();
    let finishedLineColor: UIColor = UIColor.blackColor();
    
    let thickLineThickness: CGFloat = 5;
    let midLineThickness: CGFloat = 3;
    let thinLineThickness: CGFloat = 1;
 
    //buffer for new paths
    var currentPaths = [NSValue:UIBezierPath]();
    var buffer2 = [UIBezierPath]();
    var buffer = [Bezier]();

    //The game will use this to send messages
    var gameMesage: NSString = "";
    
    //storage for accepted paths
    var finishedPaths = [UIBezierPath]();

    //game model
    var game = TicTacToeGame();

    //these are the coordinates that define where the squares are
    //they will be computed once a "#" shape is recognized
    var div0H: Int = 0;
    var div1H: Int = 0;
    var div0V: Int = 0;
    var div1V: Int = 0;
    
    //these are the midpoints of the game squares
    var r0: Int = 0;
    var r1: Int = 0;
    var r2: Int = 0;
    var c0: Int = 0;
    var c1: Int = 0;
    var c2: Int = 0;
  
    var whoseTurnIsIt: String = "anybody";
    
    var settingUpGame: Bool = true;
 
    
    ////////// Initialize the board and game
    func clearBoard(){
        currentPaths = [NSValue:UIBezierPath]();
        buffer = [Bezier](); //[UIBezierPath]();
        
        finishedPaths = [UIBezierPath]();
        settingUpGame = true;
        game.initGame();
        
        gameMesage = NSString(string: "");
        
        div1H = 0;
        div0H = 0;
        div1V = 0;
        div0V = 0;
        
        whoseTurnIsIt = "anybody";
    }
    
    ////////// React to user inputs
    func respondToLine(path: Bezier){
        
        print("Respond to line -- buffer: \(buffer.count)   finishedpaths: \(finishedPaths.count)  ");
        
        let start = path.points[0];

        //If the settingUpGame state is true -- we will try to recognize a grid.
        if(settingUpGame){
            if (buffer.count < 4) {return;}
            else if (buffer.count > 4) {
                clearBoard();
                return;
            }
            else { //try to recognize a game board
                print("Parse the gameboard");
                //Goal:
                //finishedPaths[0] is the top horizontal
                //[1] is the bottom horizontal
                //[2] is the left vertical
                //[3] is the right vertical
          
                //sort the finishedPaths on X coordinate of start point -- 3, 4 will be the vertical bars
                buffer.sortInPlace{ (p1, p2) -> Bool in
                    return p1.getLowestX().x < p2.getLowestX().x
                }
                
                //now sort the first two paths on startpoint Y coordinate
                
                if(buffer.count > 2){
                if(buffer[0].getLowestY().y > buffer[1].getLowestY().y){
                    swap(&buffer[0], &buffer[1]);
                    }
                }
                
                //Now we will create the board by cheating:
                //The drawn bars will be replaced in game logic with straight horizontal lines interpolated from the highest and lowest points
                //This has the advantage of extrapolating the grid ...
                //Any point on the screen can be used and interpreted as a valid square
                
                let div0V0: Int = Int(buffer[0].getLowestY().y);
                let div0V1: Int = Int(buffer[0].getHighestY().y);
                let div1V0: Int = Int(buffer[1].getLowestY().y);
                let div1V1: Int = Int(buffer[1].getHighestY().y);
                
                
                let div0H0: Int = Int(buffer[2].getLowestX().x);
                let div0H1: Int = Int(buffer[2].getHighestX().x);
                let div1H0: Int = Int(buffer[3].getLowestX().x);
                let div1H1: Int = Int(buffer[3].getHighestX().x);
              
                div0V = (div0V0 + div0V1) / 2;
                div1V = (div1V0 + div1V1) / 2;
                div0H = (div0H0 + div0H1) / 2;
                div1H = (div1H0 + div1H1) / 2;
                
                r0 = div0V / 2;
                r1 = (div0V + div1V) / 2;
                r2 = div1V + xOffset;
                c0 = div0H / 2;
                c1 = (div0H + div1H) / 2;
                c2 = div1H + xOffset;
           
                game.printBoard();
           
                for bez in buffer{
                    bez.redraw();
                    finishedPaths.append(bez.getPath());
                }
                
                settingUpGame = false;
                currentPaths.removeAll();
                buffer.removeAll();

            }
            
        } else { //game is running
            
            let square: Int = getGameSquare(start);
            
            print("Look for a mark");
            
            if(recognizeO() && (whoseTurnIsIt == "O" || whoseTurnIsIt == "anybody") && game.isFree(square)){ //was an O drawn?
                
                whoseTurnIsIt = "X";
                game.OPlays(square);
                print("O plays -- \(square)");
                game.printBoard();
                
                //add shape to the finished paths
                for path in buffer{
                    path.redraw();
                    finishedPaths.append(path.getPath());
                }
           
                //clear the buffer
                currentPaths.removeAll();
                buffer.removeAll();
                
                let finishLine: BoardLine = game.hasWon("O");
                
                if(finishLine.start != 0){
                    handleWin("O", start: finishLine.start, end: finishLine.end);
                }
                
                
            } else if(recognizeX() && (whoseTurnIsIt == "X" || whoseTurnIsIt == "anybody") && game.isFree(square)){ //was an X drawn?
                whoseTurnIsIt = "O";
                game.XPlays(square);
                print("X plays -- \(square)");
                game.printBoard();
                
                //add shape to finished paths
                for path in buffer{
                    path.redraw();
                    finishedPaths.append(path.getPath());
                }
                
                //clear the buffer
                buffer.removeAll();
                currentPaths.removeAll();
                
                let finishLine: BoardLine = game.hasWon("X");
                
                if(finishLine.start != 0){
                    handleWin("X", start: finishLine.start, end: finishLine.end);
                }
                
            } else{
                print("No legal move detected");
            }
            
            //No character recognized in two stokes -- kill the buffer
            if(buffer.count >= 2) {
                currentPaths.removeAll();
                buffer.removeAll();
            }
            
            //Look for and handle draws
            if(!(game.hasFreePositions()) && settingUpGame == false){
                
                gameMesage = NSString(string: "Game is a draw!!");
                settingUpGame = true;
            
            }
            
        }
    }

    //"O" is recognized if a curve's endpoint is closer to its start point than its midpoint
    func recognizeO() -> Bool{
        print(" -- recognize 'O' -- path points: \(buffer[0].points.count)");
        
        
        func distance(p1: CGPoint, p2: CGPoint) -> Int{
            let dx = p1.x - p2.x;
            let dy = p1.y - p2.y;
            
            let dist = sqrt(dx * dx + dy * dy);
            
            return Int(dist);
        }
        
        if(currentPaths.count == 2 || currentPaths.count == 0){return false;}
        
        let midindex = Int(buffer[0].points.count / 2) - 1;
        let midpoint = buffer[0].points[midindex];
        let start = buffer[0].points[0];
        let end = buffer[0].points[buffer[0].points.count-1];
        
        if(distance(start, p2: end) < distance(start, p2: midpoint)){return true;}
    
        return false;
    }
    
   
     //rule to recognize an X:
     //   - must have exactly two paths in the buffer
     //   - path1 startx > endx and path2 startx < endx, or vice versa, and
     //   - path1 starty > endy and path2 starty < endy, or vice versa, and
     //   - either path1 startx > path2 startx > path1 endx
     //           or path2 startx > path1 startx > path2 endx
     func recognizeX() -> Bool{
        
        print("Look for X -- count is \(buffer.count)");
        
        if(buffer.count != 2){
            print("Buffer not 2");
            return false;
        }
 
        let p1Start = buffer[0].points[0];
        let p1End = buffer[0].points[buffer[0].points.count - 1];
        let p2Start = buffer[1].points[0];
        let p2End = buffer[1].points[buffer[1].points.count - 1];
 
        print("p1Start -- \(p1Start)")
        print("p1End -- \(p1End)")
        print("p2Start -- \(p2Start)")
        print("p2End -- \(p2End)")
      
        if(intersects(p1Start, e1: p1End, s2: p2Start, e2: p2End)){
            print("Lines cross");
            return true;
        }
        
        print("lines did not cross");
        return false;
    }
    
    
    //Best intersection algorithm I could find
    //http://stackoverflow.com/questions/9043805/test-if-two-lines-intersect-javascript-function
    // returns true iff the line from (a,b)->(c,d) intersects with (p,q)->(r,s)
    func intersects(s1: CGPoint, e1: CGPoint, s2: CGPoint, e2: CGPoint) -> Bool {
        
        var det: Float = 0;
        var gamma: Float = 0;
        var lambda: Float = 0;
        
        let a = Float(s1.x);
        let b = Float(s1.y);
        let c = Float(e1.x);
        let d = Float(e1.y);
        let p = Float(s2.x);
        let q = Float(s2.y);
        let r = Float(e2.x);
        let s = Float(e2.y);
        
        det = ((c - a) * (s - q));
        det -= ((r - p) * (d - b));
        
        if (det == 0) {
            return false;
        } else {
            lambda = (s - q) * (r - a);
            lambda += (p - r) * (s - b);
            lambda /= det;
            gamma = (b - d) * (r - a);
            gamma += (c - a) * (s - b);
            gamma /= det;
            return (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1);
        }
    };
    
    func handleWin(winSymbol: String, start: Int, end: Int){
        print("\(winSymbol) WINS!!!");
        
        //create the finish line
        var startPoint = CGPoint();
        var endPoint = CGPoint();
        
        startPoint = getPointFromSquare(start);
        endPoint = getPointFromSquare(end);
        
        let newPath = UIBezierPath();
        newPath.moveToPoint(startPoint);
        newPath.addLineToPoint(endPoint);
        finishedPaths.append(newPath);
        
        //Set the game text
        let winString = winSymbol + " wins!!";
        gameMesage = NSString(string: winString);
      
        setNeedsDisplay();
        settingUpGame = true;
    
    }
    
    func getGameSquare(loc: CGPoint) -> Int{
        let x = Int(loc.x);
        let y = Int(loc.y);
        
        var r: Int = 0;
        var c: Int = 0;
        
        if x < div0H {c = 0;}
        else if x < div1H {c = 1;}
        else {c = 2;}
        
        if y < div0V {r = 0;}
        else if y < div1V {r = 1;}
        else {r = 2;}
    
        let position: Int = r * 3 + 1 + c;
        
        print("R: \(r)  C: \(c)")
        
        return position;
    }
    
    func drawAnX(x: Int, y: Int){
        var newLine1 = UIBezierPath();
        var newLine2 = UIBezierPath();
        
        newLine1.moveToPoint(CGPoint(x: (x-uiSymSize),y: (y-uiSymSize)));
        newLine1.addLineToPoint(CGPoint(x: (x+uiSymSize), y: (y+uiSymSize)));
        
        newLine2.moveToPoint(CGPoint(x: (x+uiSymSize),y: (y-uiSymSize)));
        newLine2.addLineToPoint(CGPoint(x: (x-uiSymSize), y: (y+uiSymSize)));
        
        finishedPaths.append(newLine1);
        finishedPaths.append(newLine2);
    
    }
    
    func drawAnO(x: Int, y: Int){
        let center = CGPoint(x: x, y: y);
        let PI: Float = 3.141592654;
        let circlePath : UIBezierPath = UIBezierPath(arcCenter: center, radius: CGFloat(uiSymSize), startAngle: CGFloat(-1 * PI / 2), endAngle: CGFloat(3 * PI / 2), clockwise: true);
        
        finishedPaths.append(circlePath);
    }
    
    
    func getPointFromSquare(square: Int) -> CGPoint{
        
        var retPoint = CGPoint();
        
        if(square == 1 || square == 2 || square == 3){
            retPoint.y = CGFloat(r0);
        } else if(square == 4 || square == 5 || square == 6 ){
            retPoint.y = CGFloat(r1);
        } else {
            retPoint.y = CGFloat(r2 + yOffset);
        }
        
        if(square == 1 || square == 4 || square == 7){
            retPoint.x = CGFloat(c0);
        } else if(square == 2 || square == 5 || square == 8 ){
            retPoint.x = CGFloat(c1);
        } else {
            retPoint.x = CGFloat(div1H + xOffset);
        }
        
        return retPoint;
        
    }

    
  //////////////////////// EVENT HANDLERS ///////////////////
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder);
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        tapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(tapRecognizer)
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer){
        print("I got a double tap")
        if(settingUpGame){
            clearBoard();
        } else if(whoseTurnIsIt == "O" || whoseTurnIsIt == "anybody"){
            whoseTurnIsIt = "X";
            let square = game.makeADefendingMove("O");
            game.OPlays(square);
            print("O plays -- \(square)");
            let loc = getPointFromSquare(square);
            let x = Int(loc.x);
            let y = Int(loc.y);
            drawAnO(x, y: y);
            game.printBoard();
            
            let finishLine: BoardLine = game.hasWon("O");
            
            if(finishLine.start != 0){
                handleWin("O", start: finishLine.start, end: finishLine.end);
            }
            
            
        } else{
            whoseTurnIsIt = "O";
            let square = game.makeADefendingMove("X");
            game.XPlays(square);
            print("X plays -- \(square)");
            let loc = getPointFromSquare(square);
            let x = Int(loc.x);
            let y = Int(loc.y);
            drawAnX(x, y: y);
            game.printBoard();
            
            let finishLine: BoardLine = game.hasWon("X");
            
            if(finishLine.start != 0){
                handleWin("X", start: finishLine.start, end: finishLine.end);
            }
            
        }
        
        setNeedsDisplay();
    }
    
    func tap(gestureRecognizer: UIGestureRecognizer){
        
        let tapPoint = gestureRecognizer.locationInView(self)
        let square: Int = getGameSquare(tapPoint);
        print("I got a tap: square \(square)");
        print("X: \(tapPoint.x)  Y: \(tapPoint.y)");
        print("H0: \(div0H)");
        print("H1: \(div1H)");
        print("V0: \(div0V)");
        print("V1: \(div1V)");
        
        setNeedsDisplay();
    }
    
 
    override func drawRect(rect: CGRect) {
        
        //draw the finished lines
        if(finishedPaths.count != 0){
            var count: Int = 0;
            for(count = 0; count < finishedPaths.count; ++count){
                if(count < 4){
                    finishedPaths[count].lineWidth = thickLineThickness;
                    gridLineColor.setStroke();
                    finishedPaths[count].stroke();
                } else if(settingUpGame && count == finishedPaths.count - 1){
                    finishedPaths[count].lineWidth = thickLineThickness;
                    gridLineColor.setStroke();
                    finishedPaths[count].stroke();
                } else{
                    finishedPaths[count].lineWidth = midLineThickness;
                    shapeColor.setStroke();
                    finishedPaths[count].stroke();
                }
            
            }

        }
        
        //draw current line if it exists
        if currentPaths.count != 0{
            for(_, path) in currentPaths{
                path.lineWidth = thinLineThickness;
                currentLineColor.setStroke();
                path.stroke();
            }
        }
        
        for bez in buffer{
            drawingLineColor.setStroke();
            bez.getPath().lineWidth = thinLineThickness;
            bez.getPath().stroke();
        }
        

        //Draw text message if it exists
        
        // set the text color to dark gray
        let fieldColor: UIColor = UIColor.blueColor()
        
        // set the font to Helvetica Neue 18
        let fieldFont = UIFont(name: "Helvetica Neue", size: 24)
        
        //set the line spacing to 6
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        
        //set the Obliqueness to 0.1
        let skew = 0.0
        
        let attributes: NSDictionary = [
            NSForegroundColorAttributeName: fieldColor,
            NSParagraphStyleAttributeName: paraStyle,
            NSObliquenessAttributeName: skew,
            NSFontAttributeName: fieldFont!
        ]
        
        if(gameMesage != ""){
            gameMesage.drawInRect(CGRectMake(20.0, 20.0, 300.0, 48.0), withAttributes: attributes as? [String : AnyObject]);
        }

    }
    
    //Override Touch Functions
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        print(__FUNCTION__) //for debugging
        for touch in touches {
            let location = touch.locationInView(self);
            let newPath = UIBezierPath();
            newPath.moveToPoint(location);
            let key = NSValue(nonretainedObject: touch);
            currentPaths[key] = newPath;
            let newBez = Bezier(p: newPath);
            newBez.addPoint(location);
            buffer.append(newBez);
        }
        setNeedsDisplay();
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInView(self);
            let key = NSValue(nonretainedObject: touch);
            currentPaths[key]?.addLineToPoint(location);
            
            for bez in buffer{
                if(bez.hasPath((currentPaths[key])!)){
                    bez.addPoint(location);
                }
            }
        }
        setNeedsDisplay();

    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print(__FUNCTION__) //for debugging
        for touch in touches {
            let location = touch.locationInView(self)
            let key = NSValue(nonretainedObject: touch)
            currentPaths[key]?.addLineToPoint(location);
            
            for bez in buffer{
                if(currentPaths[key] != nil && bez.hasPath((currentPaths[key])!)){
                    bez.addPoint(location);
                }

            }

            if(buffer.count != 0){
                respondToLine(buffer[0]);
            }
            
            setNeedsDisplay();
        }
       
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnded((touches)!, withEvent: event);
    }

}


