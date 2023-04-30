import UIKit
import Combine
import Dispatch

class ViewController: UIViewController {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var randomNumber = Int.random(in: 1...100)
    private var cancellable: AnyCancellable?
    private var startTime: Date?
    private var timerCancellable: AnyCancellable?
    private var backgroundImageView: UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImage(named: "Image")
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView?.contentMode = .scaleAspectFill
        backgroundImageView?.frame = view.bounds
        backgroundImageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundImageView!, at: 0)
        
        cancellable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: inputTextField)
            .map { notification in
                if let text = (notification.object as? UITextField)?.text, let number = Int(text) {
                    return number
                } else {
                    return nil
                }
            }
            .compactMap { $0 }
            .sink { [weak self] number in
                self?.checkNumber(number)
            }
    }
    
    
    @IBAction func restartButtonTapped(_ sender: Any) {
        randomNumber = Int.random(in: 1...100)
        hintLabel.text = "Введите число от 1 до 100"
        inputTextField.text = ""
        startTime = nil
        timerCancellable?.cancel()
        startTimer()
        cancellable = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: inputTextField)
            .map { notification in
                if let text = (notification.object as? UITextField)?.text, let number = Int(text) {
                    return number
                } else {
                    return nil
                }
            }
            .compactMap { $0 }
            .sink { [weak self] number in
                self?.checkNumber(number)
            }
    }
    
    
    
    
    private func checkNumber(_ number: Int) {
        if number > randomNumber {
            hintLabel.text = "Загаданное число меньше"
        } else if number < randomNumber {
            hintLabel.text = "Загаданное число больше"
        } else {
            hintLabel.text = "Угадали!"
            cancellable?.cancel()
            if let startTime = startTime {
                let timeInterval = Date().timeIntervalSince(startTime)
                timeLabel.text = "Прошло \(Int(timeInterval)) секунд"
            }
            startTimer()
        }
    }
    
    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                if let startTime = self?.startTime {
                    let timeInterval = Date().timeIntervalSince(startTime)
                    self?.timeLabel.text = "Прошло \(Int(timeInterval)) секунд"
                } else {
                    self?.timerCancellable?.cancel()
                }
            }
        startTime = Date()
    }
}
