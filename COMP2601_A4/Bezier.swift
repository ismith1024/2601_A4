/*********************
 
 COMP 2601 Assignment 4
 Submitted by Ian Smith #100910972
 2016-04-06
 
 *********************/

//
//  Bezier.swift
//  COMP2601_A4
//
//  Created by Ian Smith on 2016-04-04.
//  Copyright © 2016 2601. All rights reserved.
//

import Foundation
import UIKit

//Computing any geometry requires access to the points, which Apple
//seems to have forgotten to provide for the UIBezier class
//So, I have created my own class which consists of a UIBez class and
//its CGPoints.
class Bezier{
    var path: UIBezierPath;
    var points: [CGPoint];
    
    init(p: UIBezierPath){
        self.path = p;
        points = [CGPoint]();
    }
    
    func addPoint(p: CGPoint){
        points.append(p);
    }
    
    func hasPath(p: UIBezierPath)->Bool{
        return (path == p);
    }
    
    func getPath()->UIBezierPath{
        return path;
    }
    
    //Getters for the lowest and highest values of X and Y -- this is better than start and endpoints as it allows lines to be drawn either left-to-right or right-to-left
    func getLowestX()-> CGPoint{
        var lowest: CGFloat = 10000;
        var lPoint = points[0];
        for apoint in points{
            if(apoint.x < lowest){
                lowest = apoint.x;
                lPoint = apoint;
            }
            
        }
        return lPoint;
    }
    
    func getHighestX()-> CGPoint{
        var highest: CGFloat = 0;
        var lPoint = points[0];
        for apoint in points{
            if(apoint.x > highest){
                highest = apoint.x;
                lPoint = apoint;
            }
            
        }
        return lPoint;
    }
    
    func getLowestY()-> CGPoint{
        var lowest: CGFloat = 10000;
        var lPoint = points[0];
        for apoint in points{
            if(apoint.y < lowest){
                lowest = apoint.y;
                lPoint = apoint;
            }
            
        }
        return lPoint;
    }
    
    func getHighestY()-> CGPoint{
        var highest: CGFloat = 0;
        var lPoint = points[0];
        for apoint in points{
            if(apoint.y > highest){
                highest = apoint.y;
                lPoint = apoint;
            }
            
        }
        return lPoint;
        
    }
    
    //This function replaces the bezier curve with a cubic interpolated curve redrawn from the points on the curve.
    //The algorithm is sourced from a tutorial here:
    //http://code.tutsplus.com/tutorials/smooth-freehand-drawing-on-ios--mobile-13164
    func redraw(){
        
        path = UIBezierPath();
        var count: Int = 0;
        
        path.moveToPoint(points[0]);

        for (count = 0; count < points.count; count += 1){
            if ((count - 1) % 3 == 0 && count > 1 ){
                let newPoint = CGPointMake((points[count - 2].x + points[count].x)/2.0, (points[count - 2].y + points[count].y)/2.0);
                
                    path.moveToPoint(points[count - 4]);
                    path.addCurveToPoint(newPoint, controlPoint1: points[count - 2], controlPoint2: points[count - 1]);
                    
                    points[count - 1] = newPoint;
                
            } else if (count < 4){
                    path.addLineToPoint(points[count]);
            }                
        }
    }
    
    
}