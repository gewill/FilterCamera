//
//  ViewController.swift
//  FilterCamera
//
//  Created by Will on 9/8/16.
//
//

import UIKit

class ViewController: UIViewController {

    var videoCamera: GPUImageVideoCamera!
    var movieWriter: GPUImageMovieWriter!
    var skinFilter: YUGPUImageHighPassSkinSmoothingFilter!
    var hsbFilter: GPUImageHSBFilter!
    var curveFilter:GPUImageToneCurveFilter!
    var filterGroup: GPUImageFilterGroup!

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
}

