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
    var filter: YUGPUImageHighPassSkinSmoothingFilter!
    
    @IBOutlet var previewView: GPUImageView!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera!.outputImageOrientation = .Portrait;
        filter = YUGPUImageHighPassSkinSmoothingFilter()
        filter.amount = 0.7
        videoCamera?.addTarget(filter)

        filter.addTarget(previewView)
        videoCamera?.startCameraCapture()
    }

    
    @IBAction func filterSliderChanged(sender: UISlider) {
        filter.amount = CGFloat(sender.value)
    }
}

