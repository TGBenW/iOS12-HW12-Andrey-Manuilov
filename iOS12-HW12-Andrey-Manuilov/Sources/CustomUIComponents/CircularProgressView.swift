import UIKit

class CircularProgressView: UIView {

    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var didConfigureLabel = false
    var rounded: Bool
    var filled: Bool

    let lineWidth: CGFloat?

    var timeToFill = 0.23

    var progressColor = UIColor.white {
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    var trackColor = UIColor.white {
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    var progress: Float {
        didSet {
            // Calculate the duration for the animation based on the difference in progress
            let progressChange = abs(progress - oldValue)
            let animationDuration = TimeInterval(progressChange) * timeToFill

            // Update the progress of the circular view
            setProgress(to: progress, withDuration: animationDuration)
        }
    }

    func createProgressView(){
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        } else {
            trackLayer.lineWidth = lineWidth!
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        } else {
            progressLayer.lineWidth = lineWidth!
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }

    layer.addSublayer(progressLayer)
}

    func trackColorToProgressColor() {
        trackColor = UIColor(red: progressColor.cgColor.components![0],
                             green: progressColor.cgColor.components![1],
                             blue: progressColor.cgColor.components![2],
                             alpha: 0.2) // Adjust alpha for transparency
    }

    func setProgress(to newProgress: Float, withDuration duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.toValue = newProgress
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        progressLayer.add(animation, forKey: "progress")
    }

    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(frame: frame)
        filled = false
        createProgressView()
    }

    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        lineWidth = 15
        super.init(coder: coder)
        createProgressView()
    }


    init(frame: CGRect, lineWidth: CGFloat?, rounded: Bool) {
        progress = 0
        
        if lineWidth == nil{
            self.filled = true
            self.rounded = false
        } else {
            if rounded{
                self.rounded = true
            } else {
                self.rounded = false
            }
            self.filled = false
        }
        self.lineWidth = lineWidth
        
        super.init(frame: frame)
        createProgressView()
    }
}
