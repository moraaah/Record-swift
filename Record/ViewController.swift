//
//  ViewController.swift
//  Record
//
//  Created by Lidear on 16/6/20.
//  Copyright © 2016年 alex. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVAudioRecorderDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var recorder:AVAudioRecorder? //录音器
    var player:AVAudioPlayer? //播放器
    var recorderSeetingsDic:[String: AnyObject]? //录音器设置参数数组
    var volumeTimer:NSTimer! //定时器线程 循环检测录音的音量大小
    var accPath:String? //录音存储路径caf
    var mp3Path:String? //转换的mp3路径
    var startTime:Double?
    var endTime:Double?
    var starView:StarView?
    var ImageShow:GQImageShowView?
    var sheet:HJCActionSheet?
    
    @IBOutlet weak var volumLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化录音器
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        //设置录音类型
        try! session.setCategory(AVAudioSessionCategoryRecord)
        //设置支持后台
        try! session.setActive(true)
        //获取document目录
        let docPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        //组合录音文件路径
        accPath = docPath! + "/play.caf"
        mp3Path = docPath! + "/play.mp3"
        print(accPath)
        //初始化字典并添加设置参数
        recorderSeetingsDic =
        [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatLinearPCM),
            AVNumberOfChannelsKey:2, //录音的声道数 立体声为双声道
//            AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
            AVEncoderAudioQualityKey:AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey : 320000,
            AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
        ]
        
        starView = StarView.init()
        starView?.frame = CGRectMake(20, 400, 200, 50)
        starView?.font_size = 20
        starView?.show_star = 40
        starView?.canSelected = true
        self.view.addSubview(starView!)
        
        ImageShow = GQImageShowView.init(frame: CGRectMake(20, 460, UIScreen.mainScreen().bounds.size.width - 40, 100))
        ImageShow?.backgroundColor = UIColor.redColor()
        ImageShow?.isNeedAddBtn = true
        ImageShow?.isNeedDeleteBtn = true
        ImageShow?.blockClickAdd = {
            self.photo()
        }
        self.view.addSubview(ImageShow!)
    }
    
    func photo() {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            
            let cameraAction = UIAlertAction(title: "启用相机", style: .Default) { (UIAlertAction) in
                self.takePhoto()
        }
        let photoAction = UIAlertAction(title: "从相册选取", style: .Default) { (UIAlertAction) in
            self.localPhotoLib()
        }
            alertVC.addAction(cameraAction)
        alertVC.addAction(photoAction)
            alertVC.addAction(cancelAction)

        
        self.presentViewController(alertVC, animated: true, completion: nil)
        
        
    }
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker:UIImagePickerController = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            print("呵呵,你觉得模拟器能拍照吗")
        }

    }
    
    func localPhotoLib() {
        let picker = UIImagePickerController()
        picker.sourceType = .PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }

    
     func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let imageArray:NSMutableArray = []
        imageArray.addObject(image!)
        ImageShow?.addImages(imageArray)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getDeviceID() {
        
    }
 
    @IBAction func downAction(sender: AnyObject) {
        //初始化录音器
        recorder = try! AVAudioRecorder(URL: NSURL(string: accPath!)!, settings: recorderSeetingsDic!)
        recorder?.delegate = self
        if recorder != nil {
            //开始仪表计数功能
            recorder!.meteringEnabled = true
            //准备录音
            recorder!.prepareToRecord()
            //开始录音
            recorder!.record()
            
            self.startTime = CACurrentMediaTime()
            //启动定时器
            volumeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(levelTimer), userInfo: nil, repeats: true)
            
        }
        
    }

    @IBAction func upAction(sender: AnyObject) {
        recorder?.stop()
        recorder = nil
        
        self.endTime = CACurrentMediaTime()
        print("\(self.endTime! - self.startTime!)")
        
        convertToMP3()
        
        volumeTimer.invalidate()
        volumeTimer = nil
        volumLB.text = "录音音量:0"
    }

    @IBAction func playAction(sender: AnyObject) {
        player = try! AVAudioPlayer(contentsOfURL: NSURL(string: self.mp3Path!)!)
        if player == nil {
            print("播放失败")
        } else {
            player?.play()
        }
    }
    
    func levelTimer() {
        recorder!.updateMeters()
        let averageV:Float = recorder!.averagePowerForChannel(0)
        let maxV:Float = recorder!.peakPowerForChannel(0)
        let lowPassResult:Double = pow(Double(10), Double(0.05*maxV))
        volumLB.text = "录音音量:\(lowPassResult)"
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        print("complete")
    }
    
    func convertToMP3() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            CafToMp3.cafToMp3(self.accPath, toMp3Path: self.mp3Path)
        }
        
        
    }
    
}

