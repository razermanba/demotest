//
//  QuizQuestionViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/3/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import AVKit

class QuizQuestionViewController: UIViewController {
    
    var quiz =  Mapper<Quizzes>().map(JSONObject: ())
    
    var cellFillInBlank = FillinBlankTableViewCell()
    let appdelgate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var txtTime: UILabel!
    @IBOutlet weak var questionTableView: UITableView!
    private var currentTextFields: [UITextField] = []
    var dicAnswers = [String:Any]()
    var arrDicAnswers = Array<[String:Any]>()
    var question_id : String = ""
    var timer: Timer?
    var totalTime = 60
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.questionTableView.estimatedRowHeight = 150
        self.questionTableView.rowHeight = UITableView.automaticDimension
        self.questionTableView.estimatedRowHeight = 50
        self.questionTableView.rowHeight = UITableView.automaticDimension
        self.questionTableView.estimatedSectionHeaderHeight = 50
        self.questionTableView.sectionHeaderHeight =  UITableView.automaticDimension
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        questionTableView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        
        startOtpTimer()
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func submitQuiz(_ sender: Any) {
        getAnswert()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.timer?.invalidate()
        self.timer = nil
    }
    
}


extension QuizQuestionViewController : UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return quiz?.questions!.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quiz?.questions![section].options!.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .white
        
        let headingLabel = UILabel(frame: .zero)
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.text = quiz?.questions?[section].title
        headingLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        headingLabel.textColor = .black
        
        let additionalLabel = UILabel(frame: .zero)
        additionalLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalLabel.text = quiz?.questions?[section].content
        additionalLabel.numberOfLines = 0
        additionalLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        additionalLabel.textColor = .black
        
        let additionalContent = UIView(frame: .zero)
        additionalContent.translatesAutoresizingMaskIntoConstraints = false
        additionalContent.backgroundColor = .white
        additionalContent.addSubview(additionalLabel)
        additionalLabel.leadingAnchor.constraint(equalTo: additionalContent.leadingAnchor, constant: 0).isActive = true
        additionalLabel.trailingAnchor.constraint(equalTo: additionalContent.trailingAnchor, constant: -5).isActive = true
        additionalLabel.topAnchor.constraint(equalTo: additionalContent.topAnchor, constant: 8).isActive = true
        additionalContent.bottomAnchor.constraint(equalTo: additionalLabel.bottomAnchor, constant: 8).isActive = true
        
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        stackView.addArrangedSubview(headingLabel)
        stackView.addArrangedSubview(additionalContent)
        v.addSubview(stackView)
        stackView.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: 0).isActive = true
        stackView.topAnchor.constraint(equalTo: v.topAnchor, constant: 8).isActive = true
        stackView.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: 8).isActive = true
        
        return v
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let question = quiz?.questions![indexPath.section]
        
        switch question?.context {
        case "fill_blank":
            cellFillInBlank =  tableView.dequeueReusableCell(withIdentifier: "CellFillInBlank", for: indexPath) as! FillinBlankTableViewCell
            cellFillInBlank.lblContent.text = question?.options![indexPath.row].content
            cellFillInBlank.txtInputText.tag = question?.id ?? 0
            cellFillInBlank.txtInputText.delegate = self
            return cellFillInBlank
        default:
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cellAnswer", for: indexPath) as! QuizAnswerTableViewCell
            cell.lblAnswer.text = question?.options![indexPath.row].content
            
            
            if let index = arrDicAnswers.index(where: {$0["question_id"] as? String == String(format: "%d", question?.id ?? 0)}) {
                let arrchild = arrDicAnswers[index]["answer"] as! Array<Int>
                if arrchild[0] == indexPath.row {
                    selectedCell(viewBg: cell.viewBG, imgCheck: cell.imgChooice)
                }else {
                    DeSelectCell(viewBg: cell.viewBG,imgCheck: cell.imgChooice)
                    
                }
            }else {
                DeSelectCell(viewBg: cell.viewBG,imgCheck: cell.imgChooice)
            }
            
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = quiz?.questions![indexPath.section]
        question_id = String(format: "%d", question?.id ?? 0)
        
        switch question?.context {
        case "fill_blank":
            break
        default:
            let cellSelected  = tableView.cellForRow(at: indexPath as IndexPath) as! QuizAnswerTableViewCell
            selectedCell(viewBg: cellSelected.viewBG, imgCheck: cellSelected.imgChooice)
            
            var arrIndex = Array<Int>()
            arrIndex.append(indexPath.row)
            
            if let index = arrDicAnswers.index(where: {$0["question_id"] as? String == String(format: "%d", question?.id ?? 0)}) {
                arrDicAnswers.remove(at: index)
                dicAnswers = ["question_id": String(format: "%d", question?.id ?? 0),
                              "answer": [indexPath.row]]
                
                arrDicAnswers.append(dicAnswers)
            }else {
                dicAnswers = ["question_id": String(format: "%d", question?.id ?? 0),
                              "answer": [indexPath.row]]
                
                arrDicAnswers.append(dicAnswers)
            }
            
            questionTableView.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: .none)
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let question = quiz?.questions![indexPath.section]
        switch question?.context {
        case "fill_blank":
            break
        default:
            break
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            questionTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + questionTableView.rowHeight, right: 0)
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        questionTableView.contentInset = .zero
    }
}

extension QuizQuestionViewController {
    func selectedCell(viewBg : UIView, imgCheck : UIImageView)  {
        viewBg.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 1.00, alpha: 1.00)
        viewBg.layer.masksToBounds = true
        viewBg.layer.borderColor = UIColor(red: 0.28, green: 0.74, blue: 0.93, alpha: 1.00).cgColor
        viewBg.layer.borderWidth = 1.0
        imgCheck.image = UIImage.init(named: "radio-checked")
        
    }
    
    func DeSelectCell(viewBg : UIView,imgCheck : UIImageView)  {
        viewBg.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        viewBg.layer.masksToBounds = true
        viewBg.layer.borderColor = UIColor.clear.cgColor
        viewBg.layer.borderWidth = 1.0
        imgCheck.image = UIImage.init(named: "radio")
    }
}

extension QuizQuestionViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if !currentTextFields.contains(textField) { // avoid duplicates
            currentTextFields.append(textField)
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        if cellFillInBlank.txtInputText != nil {
            cellFillInBlank.txtInputText.resignFirstResponder()
            view.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
}

extension QuizQuestionViewController {
    func submitQuestion(quiz_Id : String ) {
        self.timer?.invalidate()
        self.timer = nil
        self.appdelgate?.showLoading()
        
        let duration = Int((quiz?.duration!)!)! - totalTime
        let dicQuiz = ["duration": duration,
                       "answers" : arrDicAnswers] as [String : Any]
        
        print(dicQuiz)
        
        APIService.sharedInstance.SubmitQuiz(dicQuiz as [String : AnyObject], quiz_ID: quiz_Id, completionHandle: { (result,error) in
            if error == nil {
                let dataResult = Mapper<DataResult>().map(JSONObject: result)
                self.loadViewResult(total_correct: dataResult?.total_correct ?? 0, total_question: dataResult?.total_question ?? 0)
                
                self.timer?.invalidate()
                self.timer = nil
                self.appdelgate?.dismissLoading()
            }else {
                self.appdelgate?.dismissLoading()
                let alert = UIAlertController(title: "Error", message: (error as! String), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    func getAnswert() {
        var arrayAnswer = [String]()
        var questionId = String()
        var indexText = Int()
        dicAnswers = [String:Any]()
        
        for textField in currentTextFields {
            questionId = String(format: "%d", textField.tag)
            
            if  dicAnswers["question_id"] == nil {
                dicAnswers["question_id"] = questionId
            }
            
            
            if dicAnswers["question_id"] as? String != questionId {
                dicAnswers["answer"] = arrayAnswer
                arrDicAnswers.append(dicAnswers)
                arrayAnswer.removeAll()
                
                questionId = String(format: "%d", textField.tag)
                dicAnswers["question_id"] = questionId
            }
            
            arrayAnswer.append(textField.text ?? "")
            
            indexText = indexText + 1
            
            
            if indexText == currentTextFields.count {
                dicAnswers = ["question_id": questionId,
                              "answer": arrayAnswer]
                arrDicAnswers.append(dicAnswers)
            }
        }
        
        submitQuestion(quiz_Id: String(format: "%d", quiz?.id ?? 0))
    }
}

extension QuizQuestionViewController {
    private func startOtpTimer() {
        totalTime = Int(quiz!.duration!) ?? 60
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print(self.totalTime)
        self.txtTime.text = self.timeFormatted(Int(self.totalTime)) // will show timer
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                getAnswert()
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


extension QuizQuestionViewController {
    func loadViewResult(total_correct: Int , total_question : Int) {
        let popupCompleted = (Bundle.main.loadNibNamed("PopupCompleted", owner: self, options: nil)?.first as? PopupCompleted)!
        popupCompleted.frame = self.view.frame
        popupCompleted.center = self.view.center
        
        let incorrect = total_question - total_correct
        
        popupCompleted.txtResult.text = "Correct : \(total_correct)  \nIncorrect : \(incorrect) "
        popupCompleted.btnDone.addTarget(self, action: #selector(self.actionDoneQuiz), for: .touchUpInside)
        
        self.animateViewHeight(popupCompleted, withAnimationType: CATransitionSubtype.fromTop.rawValue, andflagClose: true)
        self.view.addSubview(popupCompleted)
        
    }
    
    @objc func actionDoneQuiz (){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func animateViewHeight(_ animateView: UIView, withAnimationType animType: String, andflagClose flag: Bool) {
        let animation = CATransition()
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype(rawValue: animType)
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animateView.layer.add(animation, forKey: kCATransition)
        animateView.backgroundColor = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 0.3)
        
        if flag == false {
            animateView.isHidden = !animateView.isHidden
        }
    }
}
