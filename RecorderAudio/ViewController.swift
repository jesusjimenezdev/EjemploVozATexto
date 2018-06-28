import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var texto: UITextView!
    @IBOutlet weak var botonGrabar: UIButton!
    
    var audioSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            AVAudioSession.sharedInstance().requestRecordPermission { (permiso) in
                if permiso {
                    print("Acceso concedido")
                }
            }
            
        } catch let error as NSError {
            print("no funciona", error)
        }
        
    }

    @IBAction func grabar(_ sender: UIButton) {
        if audioRecorder == nil {
            
            let nombreAudio = directorioUrl().appendingPathComponent("audio.m4a")
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            do{
                audioRecorder = try AVAudioRecorder(url: nombreAudio, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                self.botonGrabar.setTitle("Detener grabacion", for: .normal)
            }catch let error as NSError {
                print("Error al grabar", error)
            }
            
        }else{
            audioRecorder.stop()
            audioRecorder = nil
            self.botonGrabar.setTitle("Comenzar grabacion", for: .normal)
        }
    }
    
    func directorioUrl() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let directorio = path[0]
        return directorio
    }
    
    @IBAction func reproducri(_ sender: UIButton) {
        let path = directorioUrl().appendingPathComponent("audio.m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path, fileTypeHint: AVFileType.m4a.rawValue)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("reproduciendo")
        } catch let error as NSError {
            print("no reproduce", error)
        }
        
    }
    
    @IBAction func VozAtexto(_ sender: UIButton) {
        SFSpeechRecognizer.requestAuthorization { (_) in
            DispatchQueue.main.async {
                switch SFSpeechRecognizer.authorizationStatus() {
                case .authorized:
                    let audioUrl = self.directorioUrl().appendingPathComponent("audio.m4a")
                    let recognizer = SFSpeechRecognizer()
                    let request = SFSpeechURLRecognitionRequest(url: audioUrl)
                    recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                        if let error = error {
                            print("error al reconocer texto de audio", error)
                        }else{
                            self.texto.text = result?.bestTranscription.formattedString
                        }
                    })
                    break
                default:
                    break
                }
                
            }
        }
    }
    
}

