//
//  ViewController.swift
//  FilterCamera
//
//  Created by Will on 9/8/16.
//
//

import UIKit
import AVKit

class ViewController: UIViewController, FilterHeaderViewDelegate {

    @IBOutlet var collectionViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var layout: UICollectionViewFlowLayout!

    @IBOutlet var toolBarStackView: UIStackView!

    var videoCamera: GPUImageVideoCamera!

    var skinFilter: YUGPUImageHighPassSkinSmoothingFilter!
    var hsbFilter: GPUImageHSBFilter!
    var curveFilter: GPUImageToneCurveFilter!
    var filterGroup: GPUImageFilterGroup!

    var movieWriter: GPUImageMovieWriter!

    var videoURLs = [NSURL]()

    var filterNames: [String] = ["trains", "new_2_fresh_blue", "fresh_blue", "fogy_blue", "country"]

    @IBOutlet var previewView: GPUImageView!

    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .Back)
        videoCamera.outputImageOrientation = .Portrait
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

        collectionView.registerNib(UINib(nibName: "FilterCell", bundle: nil), forCellWithReuseIdentifier: "FilterCell")
        collectionView.registerNib(UINib(nibName: "FilterHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "FilterHeaderView")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }

    // MARK: - 美颜值
    @IBAction func filterSliderChanged(sender: UISlider) {
        skinFilter.amount = CGFloat(sender.value)
    }

    // MARK: - HSB
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

    // MARK: - 录像
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

    // MARK: - 更改滤镜
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

    @IBAction func changeFilterButtonClick(sender: UIButton) {
        collectionViewToBottomConstraint.constant = 0
        toolBarStackView.hidden = true
    }

    // MARK: - 预览滤镜集合视图
    // MARK: - UICollectionViewDelegate
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {

        return 1

    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return filterNames.count

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as! FilterCell

        cell.previewImageView.image = UIImage(named: "filter_preview")

        cell.nameLabel.text = filterNames[indexPath.item]
        if cell.selected == true {
            cell.nameLabel.backgroundColor = UIColor.redColor()
            cell.nameLabel.textColor = UIColor.whiteColor()
        } else {
            cell.nameLabel.backgroundColor = UIColor.whiteColor()
            cell.nameLabel.textColor = UIColor.redColor()
        }

        return cell

    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {

        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "FilterHeaderView", forIndexPath: indexPath) as! FilterHeaderView
            
            header.delegate = self
            
            return header
        } else {
            return UICollectionReusableView()
        }


    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCell else { return }

        changeFilterWithACVFileName(filterNames[indexPath.item])

        if cell.selected == true {
            cell.nameLabel.backgroundColor = UIColor.redColor()
            cell.nameLabel.textColor = UIColor.whiteColor()
        } else {
            cell.nameLabel.backgroundColor = UIColor.whiteColor()
            cell.nameLabel.textColor = UIColor.redColor()
        }

    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {

        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCell else { return }

        if cell.selected == true {
            cell.nameLabel.backgroundColor = UIColor.redColor()
            cell.nameLabel.textColor = UIColor.whiteColor()
        } else {
            cell.nameLabel.backgroundColor = UIColor.whiteColor()
            cell.nameLabel.textColor = UIColor.redColor()
        }

    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return CGSize(width: 60, height: 60 + 26)

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return CGSize(width: 30, height: UIScreen.mainScreen().bounds.width)

    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {

        return CGSizeZero

    }

    // MARK: - FilterHeaderViewDelegate
    func filterHeaderViewDidClickDoneButton(header: UICollectionReusableView, doneButton: UIButton) {
        collectionViewToBottomConstraint.constant = -106
        toolBarStackView.hidden = false
    }

    // MARK: - private method
    private func changeFilterWithACVFileName(name: String) {
        videoCamera.pauseCameraCapture()

        videoCamera.removeAllTargets()
        filterGroup.removeAllTargets()

        curveFilter = GPUImageToneCurveFilter(ACV: name)

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

