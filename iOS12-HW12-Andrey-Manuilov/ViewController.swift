import UIKit
import SnapKit

class ViewController: UIViewController {

    //MARK: - Variables
    private let buttonSize: CGFloat = 60 // button size
    private let circleDiameter = 360 // progress bar circle diameter
    private let darkGreen = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1) // custom green color for UI
    
    private var isWorkTime = true // ↓ variables for progress bar circle
    private var isStarted = false
    private var timer: Timer?
    private var workSeconds = 25 // 25 seconds
    private var breakSeconds = 5 // 5 seconds
    private var currentSeconds = 0
    
    //MARK: - Outlets

    private lazy var labelPomodoro: UILabel = {
        let label = UILabel()
        label.text = "Pomodoro" // Текст
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelTimer: UILabel = {
        let label = UILabel()
        label.text = "Timer"
        label.textAlignment = .center
        label.textColor = .red
        label.transform = CGAffineTransform(rotationAngle: -12 * .pi / 180)
        label.font = UIFont(name: "BradleyHandITCTT-Bold", size: 48) ?? UIFont.systemFont(ofSize: 48, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelCountdown: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "00:25", attributes: [.kern: -3.0])
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .light)
        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "play")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        let largeIconConfig = UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .light, scale: .default) // icon size config
        let largeIcon = image?.applyingSymbolConfiguration(largeIconConfig)

        button.setImage(largeIcon, for: .normal)
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        
        button.imageView?.contentMode = .center
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var progressCircle: CircularProgressView = {
        let progressCircle = CircularProgressView(frame: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter), lineWidth: 5, rounded: false)
        progressCircle.progressColor = .red
        progressCircle.trackColor = .lightGray
        progressCircle.trackColorToProgressColor()
        progressCircle.progress = 1.0
        progressCircle.isUserInteractionEnabled = false
        return progressCircle
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "reset")

        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)

        button.imageView?.contentMode = .center
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton()
        let infoIconConfig = UIImage.SymbolConfiguration(pointSize: buttonSize*0.85, weight: .light, scale: .default)
        let image = UIImage(systemName: "info.circle")?.withTintColor(.label, renderingMode: .alwaysOriginal).applyingSymbolConfiguration(infoIconConfig)

        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)

        button.imageView?.contentMode = .center
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Lifestyle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHierarchy()
        setupLayout()
    }

    //MARK: - Setup
    
    private func setupView() {
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "BG_image")
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    
    private func setupHierarchy() {
        view.addSubview(labelPomodoro)
        view.addSubview(labelTimer)
        view.addSubview(labelCountdown)
        view.addSubview(playButton)
        view.addSubview(progressCircle)
        view.addSubview(resetButton)
        view.addSubview(infoButton)
    }
    
    private func setupLayout() {
        labelPomodoro.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalToSuperview()
        }
        
        labelTimer.snp.makeConstraints { make in
            make.top.equalTo(labelPomodoro.snp.bottom).offset(-20)
            make.right.equalTo(labelPomodoro.snp.right).offset(48)
        }
        
        labelCountdown.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        playButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
        }
        
        progressCircle.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(circleDiameter)
        }
        
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-25)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-30)
        }
        
        infoButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(20)
        }
    }
    
    //MARK: - Actions
    
    @objc private func playButtonTapped() {
        if isStarted {
            pauseTimer()
        } else {
            if currentSeconds == 0 {
                resetTimer()
            }
            startTimer()
        }
        isStarted.toggle()
        updateButtonImage()
    }
    
    @objc private func resetButtonTapped() {
        timer?.invalidate()
        timer = nil

        isWorkTime = true
        isStarted = false
        currentSeconds = workSeconds

        updateButtonImage()
        updateCountdownLabel()
        progressCircle.setProgress(to: 1.0, withDuration: 0.0) // instant progress circle fill

        labelCountdown.textColor = .red
        playButton.tintColor = .red
        progressCircle.progressColor = .red
        progressCircle.trackColorToProgressColor()
    }
    
    @objc private func infoButtonTapped() { // alert with information about the Pomodoro technique
        let message = "The Pomodoro Technique is a time management method. Work for 25 minutes, then take a 5-minute break."
        let alertController = UIAlertController(title: "Pomodoro Technique", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        updateButtonImage()
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        updateButtonImage()
    }
    
    @objc private func updateTimer() {
        if currentSeconds > 0 {
            currentSeconds -= 1
        } else {
            isWorkTime.toggle()
            currentSeconds = isWorkTime ? workSeconds : breakSeconds

            if isWorkTime { // set progress bar color to work/break mode
                progressCircle.progressColor = .red
                labelCountdown.textColor = .red
                playButton.tintColor = .red
            } else {
                progressCircle.progressColor = darkGreen
                labelCountdown.textColor = darkGreen
                playButton.tintColor = darkGreen
            }
            progressCircle.trackColorToProgressColor() // update track color
        }

        let totalDuration = isWorkTime ? workSeconds : breakSeconds
        let progress = (Float(currentSeconds) / Float(totalDuration))
        progressCircle.setProgress(to: progress, withDuration: 1.0)

        updateCountdownLabel()
        updateButtonImage()
    }
    
    private func resetTimer() {
        currentSeconds = workSeconds
        updateCountdownLabel()
    }
    
    private func switchToWorkTime() {
        currentSeconds = workSeconds
        isWorkTime = true
        updateCountdownLabel()
        updateButtonImage()
    }
    
    private func switchToBreakTime() {
        currentSeconds = breakSeconds
        isWorkTime = false
        updateCountdownLabel()
        updateButtonImage()
    }
    
    private func switchToCurrentMode() {
        if isWorkTime {
            switchToBreakTime()
        } else {
            switchToWorkTime()
        }
    }
    
    private func updateCountdownLabel() {
        let minutes = currentSeconds / 60
        let seconds = currentSeconds % 60
        labelCountdown.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func updateButtonImage() {
        let largeIconConfig = UIImage.SymbolConfiguration(pointSize: buttonSize, weight: .regular, scale: .default)
        
        let iconName = isStarted ? "pause" : "play"
        if let image = UIImage(systemName: iconName)?.withTintColor(isWorkTime ? .red : darkGreen, renderingMode: .alwaysOriginal).applyingSymbolConfiguration(largeIconConfig) {
            playButton.setImage(image, for: .normal)
        }
    }
}
