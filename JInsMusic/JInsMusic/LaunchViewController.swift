//
//  LaunchViewController.swift
//  JInsMusic
//
//  Created by スーパー on 2019/10/17.
//  Copyright © 2019 出口裕貴. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController{
    @IBOutlet weak var iconview: UIImageView!
    @IBOutlet weak var circleview: UIImageView!
    @IBOutlet weak var logoview: UIImageView!
    
    var timer :Timer!
    var timecount:Double = 0
    
    var circlesize:Int = 0
    var iconsize:Int = 0
    var logoaipha:CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rect:CGRect = CGRect(x:375/2, y:812/2, width:iconsize, height:iconsize)
        iconview.frame = rect
        circleview.frame = rect
        logoview.alpha = CGFloat(logoaipha)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (t) in
            self.timeranimete()
        })
        
    }

    func timeranimete(){
        timecount = timecount + 0.01
        if timecount <= 0.3{
            iconsize += 3
            circlesize += 33
        }else if timecount <= 0.6{
            iconsize -= 1
            logoaipha += 1/30
        }else if timecount <= 0.9{
            
        }else{
            performSegue(withIdentifier: "launch", sender: nil)
        }
        let iconrect = CGRect(x:(375-iconsize)/2, y:(812-iconsize)/2, width:iconsize, height:iconsize)
        let circlerect = CGRect(x:(375-circlesize)/2, y:(812-circlesize)/2, width:circlesize, height:circlesize)
        iconview.frame = iconrect
        circleview.frame = circlerect
        logoview.alpha = CGFloat(logoaipha)
    }
}
