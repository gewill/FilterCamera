//
//  ViewController.swift
//  FilterCamera
//
//  Created by Will on 9/8/16.
//
//

import UIKit
import AVKit

class ViewController: UIViewController {

    var videoCamera: GPUImageVideoCamera!

    var skinFilter: YUGPUImageHighPassSkinSmoothingFilter!
    var hsbFilter: GPUImageHSBFilter!
    var curveFilter: GPUImageToneCurveFilter!
    var filterGroup: GPUImageFilterGroup!

    var movieWriter: GPUImageMovieWriter!

    var videoURLs = [NSURL]()

    @IBOutlet var previewView: GPUImageView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait;
        skinFilter = YUGPUImageHighPassSkinSmoothingFilter()
        skinFilter.amount = 0.7

        hsbFilter = GPUImageHSBFilter()
        hsbFilter.reset()

        curveFilter = GPUImageToneCurveFilter(ACV: "new_2_fresh_blue")

        filterGroup = GPUImageFilterGroup()
        filterGroup.addFilter(skinFilter)
        filterGroup.addFilter(hsbFilter)
        filterGroup.addFilter(curveFilter)

        skinFilter.addTarget(hsbFilter)
        hsbFilter.addTarget(curveFilter)
        filterGroup.initialFilters = [skinFilter]
        filterGroup.terminalFilter = curveFilter

        videoCamera?.addTarget(filterGroup)

        filterGroup.addTarget(previewView)
        videoCamera?.startCameraCapture()
    }

    @IBAction func filterSliderChanged(sender: UISlider) {
        skinFilter.amount = CGFloat(sender.value)
    }

    @IBAction func resetHSBButtonClick(sender: UIButton) {
        hsbFilter.reset()
    }
    @IBAction func resetHButtonClick(sender: UIButton) {
        hsbFilter.rotateHue(0)
    }
    @IBAction func resetSButtonClick(sender: UIButton) {
        hsbFilter.adjustSaturation(50)
    }
    @IBAction func resetBButtonClick(sender: UIButton) {
        hsbFilter.adjustBrightness(50)
    }
    @IBAction func hSliderChanged(sender: UISlider) {
        hsbFilter.rotateHue(sender.value)
        print(sender.value)
        print(hsbFilter.description)
    }
    @IBAction func sSliderChanged(sender: UISlider) {
        hsbFilter.adjustSaturation(sender.value)
        print(sender.value)
        print(hsbFilter.description)
    }
    @IBAction func bSliderChanged(sender: UISlider) {
        hsbFilter.adjustBrightness(sender.value)
        print(sender.value)
        print(hsbFilter.description)
    }

    // 录像
    @IBAction func startButtonClick(sender: UIButton) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        let dataPath = documentsDirectory.stringByAppendingPathComponent(NSUUID().UUIDString + ".m4v") as String
        let url = NSURL(fileURLWithPath: dataPath)
        videoURLs.append(url)

        movieWriter = GPUImageMovieWriter(movieURL: url, size: CGSize(width: 480, height: 640))

        movieWriter.encodingLiveVideo = true
        filterGroup.addTarget(movieWriter)
        videoCamera.audioEncodingTarget = movieWriter
        movieWriter.startRecording()
    }
    @IBAction func stopButtonClick(sender: UIButton) {
        filterGroup.removeTarget(movieWriter)
        videoCamera.audioEncodingTarget = nil
        movieWriter.finishRecording()

    }
    @IBAction func openButtonClick(sender: UIButton) {
        guard let url = videoURLs.last else { return }

        let vc = AVPlayerViewController()
        vc.player = AVPlayer(URL: url)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // 更改滤镜
//    videoCamera.removeAllTargets()
//    filter.removeAllTargets()
//    filter = GPUImageSepiaFilter()
//    videoCamera.addTarget(filter)
//    filter.addTarget(filterView)
//    filter.prepareForImageCapture()

    @IBAction func changeFilter1ButtonClick(sender: UIButton) {
        videoCamera.pauseCameraCapture()

        videoCamera.removeAllTargets()
        filterGroup.removeAllTargets()

        curveFilter = GPUImageToneCurveFilter(ACV: "fogy_blue")

        filterGroup = GPUImageFilterGroup()
        filterGroup.addFilter(skinFilter)
        filterGroup.addFilter(hsbFilter)
        filterGroup.addFilter(curveFilter)

        skinFilter.addTarget(hsbFilter)
        hsbFilter.addTarget(curveFilter)
        filterGroup.initialFilters = [skinFilter]
        filterGroup.terminalFilter = curveFilter

        videoCamera?.addTarget(filterGroup)

        filterGroup.addTarget(previewView)
        videoCamera?.startCameraCapture()

        videoCamera.resumeCameraCapture()

    }
    @IBAction func changeFilter2ButtonClick(sender: UIButton) {
        videoCamera.pauseCameraCapture()
        
        videoCamera.removeAllTargets()
        filterGroup.removeAllTargets()
        
        curveFilter = GPUImageToneCurveFilter(ACV: "trains")
        
        filterGroup = GPUImageFilterGroup()
        filterGroup.addFilter(skinFilter)
        filterGroup.addFilter(hsbFilter)
        filterGroup.addFilter(curveFilter)
        
        skinFilter.addTarget(hsbFilter)
        hsbFilter.addTarget(curveFilter)
        filterGroup.initialFilters = [skinFilter]
        filterGroup.terminalFilter = curveFilter
        
        videoCamera?.addTarget(filterGroup)
        
        filterGroup.addTarget(previewView)
        videoCamera?.startCameraCapture()
        
        videoCamera.resumeCameraCapture()
    }

}

