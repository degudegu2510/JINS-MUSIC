//
//  ViewController.swift
//  JInsMusic
//
//  Created by スーパー on 2019/07/11.
//  Copyright © 2019 出口裕貴. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController, MEMELibDelegate,AVAudioPlayerDelegate {
    
    @IBOutlet weak var cdbutton: UIButton!
    @IBOutlet weak var chargView: UIImageView!
    @IBOutlet weak var headview: UIImageView!
    @IBOutlet weak var mindview: UIImageView!
    @IBOutlet weak var bodyview: UIImageView!
    @IBOutlet weak var headlabel: UILabel!
    @IBOutlet weak var mindlabel: UILabel!
    @IBOutlet weak var bodylabel: UILabel!
    
    
    var first20timer:Timer!
    var first20timerState:Bool = true //最初の20秒タイマーの状態
    var first20:Bool = true//20秒たってない
    var head:Int = 0
    var mind:Int = 0
    var body:Int = 0
    var blinkarray = [UInt8]()
    var strengtharray = [Int]()
    var oldstrength:UInt16!
    
    var musicbool:Bool=false
    var radiusbutton:Double = 0

    var accXarray = [Float]()
    var accYarray = [Float]()
    var accZarray = [Float]()
    var accsumarray = [Float]()
    
    var audioPlayer1:AVAudioPlayer!
    var audioPlayer2:AVAudioPlayer!
    var soundname:[String] = ["sound1","sound2","sound3","sound4","sound5","sound6"]
    var soundnum:Int = 0
    
    var crossvolumeTimer:Timer!
    var crossvolumecount:Int = 50
    var audioplayer1volume:Float=0
    var audioplayer2volume:Float=1
    var playernum:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //MEMELib.sharedInstance()?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        MEMELib.sharedInstance()?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func memeAppAuthorized(_ status: MEMEStatus) {
        MEMELib.sharedInstance()?.startScanningPeripherals()
    }
    
    func memePeripheralFound(_ peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance()?.connect(peripheral)
    }
    
    func memePeripheralConnected(_ peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance()?.startDataReport()
        print (status as Any)
    }
    
    func memeRealTimeModeDataReceived(_ data: MEMERealTimeData!) {
        print(data.fitError)
        if data.fitError == UInt8(0){
        //接続されてる時
            do{
                if data.blinkStrength > 0{
                    mind =  try checkMEMEmindPoint(strength: data.blinkStrength)
                }
                head = checkMEMEheadPoint(speed: data.blinkSpeed)
                body = cheakMEMEbodyPoint(accX: data.accX, accY: data.accY, accZ: data.accZ)
            }catch{}
            print("headpoint:",head,"mindpoint:",mind,"bodypoint:",body,"lv:",data.powerLeft)
            forceview(mind: mind, body: body, head: head,charg: data!.powerLeft)
        }
        
        //ボタン回転
        if musicbool == true{
            radiusbutton += 10
            let angle:CGFloat = CGFloat((Float(radiusbutton) * Float.pi) / 180.0)
            cdbutton.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    @IBAction func cdaction(_ sender: Any) {
        
        if musicbool == false{
            musicbool = true
            //shadowをつける(再生)
            cdbutton.layer.shadowColor = UIColor.black.cgColor
            cdbutton.layer.shadowOpacity = 0.25
            cdbutton.layer.shadowRadius = 6
            crossvolumeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
                self.timecontent()
            })
            
        }else if musicbool == true{
            //shadowを消す(再生してない)
            musicbool = false
            cdbutton.layer.shadowColor = UIColor.black.cgColor
            cdbutton.layer.shadowOpacity = 0
            cdbutton.layer.shadowRadius = 6
            audiostop()
            crossvolumeTimer.invalidate()
            //初期設定
            crossvolumecount = 50
            audioplayer1volume = 0
            audioplayer2volume = 1
            playernum = 1
            
            
        }
        
    }
    
    //headpoint測定
    func checkMEMEheadPoint(speed:UInt8) -> Int{
        var blinksum:Double = 0
        var headpoint:Int = 0
        
        //最初の２０秒たってるかを調べる
        if first20timerState==true{
            first20timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { (t) in
               self.first20 = false
            })
            first20timerState = false
        }
        
        //データを挿入
        blinkarray.append(speed)
        if first20 == false{
            blinkarray.remove(at: 0)
        }
        
        for i in 0 ..< blinkarray.count{
            if blinkarray[i] > 0{
                blinksum = blinksum + 1
            }
        }
        //計算
        let brinkrate = blinksum / 20
        headpoint = Int((0.5655 - brinkrate)/0.0026)
        if headpoint > 100{
            headpoint = 100
        }else if headpoint < 0{
            headpoint = 0
        }
        
        return headpoint
    }
    
    //mindpoint測定
    func checkMEMEmindPoint(strength:UInt16) throws -> Int{
        
        var strengthsloep:Int!
        var sumstrength:Int = 0
        var mindpoint:Int = 0
        
        if strength > 0{
            if oldstrength == nil{
                oldstrength = 0
            }
            
            if oldstrength > strength {
                strengthsloep = Int(oldstrength - strength)
            }else{
                strengthsloep = Int(strength - oldstrength)
            }
            
            strengtharray.append(strengthsloep)
            if strengtharray.count > 5{
                strengtharray.remove(at: 0)
            }
            
            for i in 0..<strengtharray.count{
                sumstrength = sumstrength + strengtharray[i]
            }
            if 250 > sumstrength {
                mindpoint = 100
            }else if sumstrength > 500{
                mindpoint = 0
            }else{
                mindpoint = 100 - Int(sumstrength / 5 * 2 - 100)
            }
            oldstrength = strength
        }
        return mindpoint
    }
    
    //bodypoint測定
    func cheakMEMEbodyPoint(accX:Float,accY:Float,accZ:Float)->Int{
        var bodypoint:Int!
        //accX
        var accXsum:Float = 0
        accXarray.append(accX)
        if accXarray.count > 5{
            accXarray.remove(at: 0)
        }
        for i in 0 ..< accXarray.count{
            accXsum = accXsum + accXarray[i]
        }
        
        //accY　25付近
        var accYsum:Float = 0
        accYarray.append(accY)
        if accYarray.count > 5{
            accYarray.remove(at: 0)
        }
        for i in 0 ..< accYarray.count{
            accYsum = accYsum + accYarray[i]
        }
        
        //accZ 0付近
        var accZsum:Float = 0
        accZarray.append(accZ)
        if accZarray.count > 5{
            accZarray.remove(at: 0)
        }
        for i in 0 ..< accZarray.count{
            accZsum = accZsum + accZarray[i]
        }
        //point算出
        let accsum = accX + accY + accZ
        if accsum > 3{
            bodypoint = 0
        }else if accsum < -10{
            bodypoint = 100
        }else{
            bodypoint = Int((accsum - 3)*100/(-10-3))
        }
        return bodypoint
    }
    
    //viewを変更する関数
    func forceview(mind:Int!,body:Int!,head:Int!,charg:UInt8){

        if head != nil{
            headlabel.text = String(head)
            if head>=60{
                headview.image = UIImage(named: "head_red.png")
            }else{
                headview.image = UIImage(named: "head_gray.png")
            }
        }else{
            headlabel.text = "--"
        }
        if mind != nil{
            mindlabel.text = String(mind)
            if mind>=60{
                mindview.image = UIImage(named: "hart_red.png")
            }else{
                mindview.image = UIImage(named: "hart_gray.png")
            }
        }else{
            mindlabel.text = "--"
        }
        if body != nil{
            bodylabel.text = String(body)
            if body>=60{
                bodyview.image = UIImage(named: "body_red.png")
            }else{
                bodyview.image = UIImage(named: "body_gray.png")
            }
        }else{
            bodylabel.text = "--"
        }
        
        if charg == 0{
            chargView.image = UIImage(named: "charg-ing.png")
        }else if charg == 1{
            chargView.image = UIImage(named: "charg-lv1.png")
        }else if charg == 2{
            chargView.image = UIImage(named: "charg-lv2.png")
        }else if charg == 3{
            chargView.image = UIImage(named: "charg-lv3.png")
        }else if charg == 4{
            chargView.image = UIImage(named: "charg-lv4.png")
        }else if charg == 5{
            chargView.image = UIImage(named: "charg-max.png")
        }
        
    }
    
    //Audioを再生させる
    func Audioplay(){
        soundnum += 1
        let named = soundnum % 6
        
        let audiopath = Bundle.main.path(forResource: soundname[named], ofType: "mp3")!
        let audiourl = URL(fileURLWithPath: audiopath )
        
        var audioError:NSError?
        //
        if playernum == 1{
            
            do {
                audioPlayer1 = try AVAudioPlayer(contentsOf: audiourl)
            } catch let error as NSError {
                audioError = error
                audioPlayer1 = nil
            }
            // エラーが起きたとき
            if let error = audioError {
                print("Error \(error.localizedDescription)")
            }
            audioPlayer1.prepareToPlay()
            //音が停止中の場合は再生する。
            playernum = 2
            if(audioPlayer1.isPlaying) {
                //音が再生中の場合は停止する。
                audioPlayer1.stop()
                audioPlayer1.currentTime = 0
            } else {
                audioPlayer1.play()
            }
        }
        else if playernum == 2{
            do {
                audioPlayer2 = try AVAudioPlayer(contentsOf: audiourl)
            } catch let error as NSError {
                audioError = error
                audioPlayer2 = nil
            }
            // エラーが起きたとき
            if let error = audioError {
                print("Error \(error.localizedDescription)")
            }
            audioPlayer2.prepareToPlay()
            //音が停止中の場合は再生する
            playernum = 1
            if(audioPlayer2.isPlaying) {
                //音が再生中の場合は停止する。
                audioPlayer2.stop()
                audioPlayer2.currentTime = 0
            } else {
                audioPlayer2.play()
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
         Audioplay()
    }
    
    func audiostop(){
        audioPlayer1.stop()
        audioPlayer2.stop()
    }

    func timecontent(){
        crossvolumecount += 1
        var volume1 : Float = 1.0
        //クロスフェード
        if 0<=crossvolumecount && crossvolumecount<=10{
            if Float(1-crossvolumecount/10) < volume1{
                if playernum == 2{
                    audioplayer1volume += 0.1
                    audioPlayer1.volume = audioplayer1volume
                    audioplayer2volume -= 0.1
                    print(audioplayer2volume)
                    if audioPlayer2 != nil{
                        audioPlayer2.volume = audioplayer2volume
                    }
                }else{
                    audioplayer1volume -= 0.1
                    audioPlayer1.volume = audioplayer1volume
                    audioplayer2volume += 0.1
                    audioPlayer2.volume = audioplayer2volume
                }
            }
        }else if crossvolumecount > 50{
            crossvolumecount = 0
            Audioplay()
        }else{
            volume1 = Float(1 - round(Double(head / 10/*7.4を四捨五入で7*/)) / 10)
            print("valume1:",volume1)
            if playernum == 2{
                audioPlayer1.volume = volume1
            }else if playernum == 1{
                audioPlayer2.volume = volume1
            }
        }
    }
}

