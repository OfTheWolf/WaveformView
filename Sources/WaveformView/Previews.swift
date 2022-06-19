//
//  SwiftUIView.swift
//  
//
//  Created by Ugur Bozkurt on 19/06/2022.
//

import SwiftUI
import AVFoundation

struct Previews: PreviewProvider{
    
    static func getFloatBuffers(from url: URL) throws -> [Float]{
        let file = try AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)!
        
        let buf = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length))!
        try file.read(into: buf)
        
        // this makes a copy, you might not want that
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData![0], count:Int(buf.frameLength)))
        return floatArray
    }
    
    static func downsample(_ floatArray: [Float], samplingFactor: CGFloat) -> [Float]{
        let samplingFactor = 512
        let newSize = ceil(Double(floatArray.count)/Double(samplingFactor))
        var downsampled = [Float](repeating: 0, count: Int(newSize))
        var bin: [Float] = []
        
        floatArray.enumerated().forEach { value in
            if value.offset % samplingFactor == 0{
                downsampled[value.offset / samplingFactor] = bin.max() ?? value.element
                bin.removeAll()
            }else{
                bin.append(value.element)
            }
        }
        return downsampled
    }
    
    static var previews: some View{
        
        let url = Bundle.module.url(forResource: "test", withExtension: "mp3")!
        
        let floatArray = try! getFloatBuffers(from: url)
        let downsampled = downsample(floatArray, samplingFactor: 512)
        
        let values = Binding.constant(downsampled.map(CGFloat.init))
        let original = Binding.constant(floatArray.map(CGFloat.init))

        return NavigationView{
            VStack(){
                Spacer()
                
                VStack{
                    Text("Original")
                        .font(.headline)
                    WaveformView(data: original)
                        .fill(.blue)
                        .border(.gray)
                        .background(.yellow)
                        .padding(.horizontal)
                    
                    Text("Downsampled")
                        .font(.headline)
                    WaveformView(data: values)
                        .fill(.blue)
                        .border(.gray)
                        .background(.yellow)
                        .padding(.horizontal)
                }
                .frame(width: .infinity, height: 500)
                .padding()
                
                Spacer()
            }
            .background(.regularMaterial)
            .navigationTitle("Audio Waveforms")
        }
    }
}
