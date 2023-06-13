//
//  LocalView.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 15/05/2023.
//

import SwiftUI
import AVFoundation

struct LocalView: View {
    @StateObject private var captureManager = CaptureManager()
    
    var body: some View {
            // Display the video preview using an AVPlayerLayer
        VideoPreviewLayerView(playerLayer: captureManager.previewLayer)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                captureManager.startCaptureSession()
            }
            .onDisappear {
                captureManager.stopCaptureSession()
            }
    }
}

struct LocalView_Previews: PreviewProvider {
    static var previews: some View {
        LocalView()
    }
}

    // A custom SwiftUI view that wraps an AVPlayerLayer
struct VideoPreviewLayerView: UIViewRepresentable {
    let playerLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect.zero)
        if let playerLayer = playerLayer {
            view.layer.addSublayer(playerLayer)
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        playerLayer?.frame = uiView.bounds
    }
}

    // A manager class to handle the capture session setup and management
class CaptureManager: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        return videoPreviewLayer
    }
    
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
                self.videoOutput = videoOutput
            }
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            self.videoPreviewLayer = videoPreviewLayer
        } catch {
            print("Error setting up capture session: \(error)")
        }
    }
    
    func startCaptureSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopCaptureSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
        // Implement the delegate method to receive video frames
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Check if the output is video data output
        guard let videoOutput = output as? AVCaptureVideoDataOutput else {
            return
        }
        
            // Check if the sample buffer contains video pixel data
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
            // Process the video frame using the pixel buffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let uiImage = UIImage(ciImage: ciImage)
            // Use the UIImage or CIImage for further processing or displaying purposes

    }

}
