import SwiftUI

public struct WaveformView: Shape{
    @Binding private var values: [CGFloat]
    private let spacing: CGFloat
    
    public init(data: Binding<[CGFloat]>, spacing: CGFloat = 0.2) {
        _values = data
        self.spacing = spacing
    }

    public func path(in rect: CGRect) -> Path {
        let count = CGFloat(values.count)
        let lineWidth = (rect.width - count*spacing) / (count)
        
        let scale = 1.0 / (values.max()! - values.min()!)

        var path = Path()
        values.enumerated().forEach { offset, value in
            let x = CGFloat(offset) * (lineWidth + spacing)
            let y = rect.height * value * scale
            path.move(to: CGPoint(x: x, y: rect.midY - y/2))
            path.addLine(to: .init(x: x, y: rect.midY + y/2))
        }
        path.closeSubpath()
        return path
            .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
    }
}
