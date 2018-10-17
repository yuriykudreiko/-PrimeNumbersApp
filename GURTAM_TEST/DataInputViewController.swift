//
//  ViewController.swift
//  GURTAM_TEST
//
//  Created by Yra on 15.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    
    static let myFont : UIFont = UIFont.systemFont(ofSize: 14)
    
    static func createTextFieldWith(placeholder: String, keyboardType: UIKeyboardType, returnKey: UIReturnKeyType) -> UITextField {
        let sampleTextField = UITextField()
        sampleTextField.placeholder = placeholder
        sampleTextField.font = myFont
        sampleTextField.borderStyle = UITextBorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = keyboardType
        sampleTextField.returnKeyType = UIReturnKeyType.next
        sampleTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        sampleTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        return sampleTextField
    }
    
    static func createLabelWith(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = myFont
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.backgroundColor = .white
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }
    
    static func createButton(text: String, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.backgroundColor = color
        button.layer.cornerRadius = 10
        button.titleLabel?.font = myFont
        button.setTitleColor(.gray, for: .normal)
        return button
    }
}

class DataInputViewController: UIViewController, ResultTableViewControllerDelegate {

    // MARK: - Properties
    
    var calculation: Calculation?
    
    // MARK: - Items
    
    let calculationButton : UIButton = {
        let button = createButton(text: "Расчет", color: .blue)
        button.addTarget(self, action: #selector(calculationAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    let numberTextField : UITextField = {
        let sampleTextField = createTextFieldWith(placeholder: "Input number", keyboardType: .numberPad, returnKey: .done)
        return sampleTextField
    }()
    
    let resultLabel : UILabel = {
        let label = createLabelWith(text: "")
        return label
    }()
    
    let progressView : UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.setProgress(0.0, animated: true)
        view.progressTintColor = .green
        view.trackTintColor = .gray
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        layoutSetup()
        progressView.isHidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(memoryClearAction(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showResultsAction(_:)))
    }

    // MARK: - Layout
    
    private func createStackViewWith(subviews: [UIView]) -> UIStackView {
        
        let line = UIStackView(arrangedSubviews: subviews)
        line.distribution = .fillEqually
        line.spacing = 10
        return line
    }
    
    private func layoutSetup() {
        
        let firstLine = createStackViewWith(subviews: [numberTextField, calculationButton])
        view.addSubview(firstLine)
        firstLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            firstLine.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            firstLine.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            firstLine.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            firstLine.heightAnchor.constraint(equalToConstant: 50)
            ]
        )
        
        view.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: firstLine.bottomAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            resultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            resultLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            ]
        )
        
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 20),
            progressView.widthAnchor.constraint(equalToConstant: 200)
            ]
        )
    }
    
    // MARK: - Help methods

    func isPrime(_ number: Int) -> Bool {
        return number > 1 && !(2..<number).contains { number % $0 == 0 }
    }
    
    func updateProgressViewWith(number: Int) {
        progressView.isHidden = false
        if progressView.progress != 1.0 {
            progressView.progress += 1 / Float(number)
        }
    }
    
    func saveCalculationWith(numbers: [Int32], maxNumber: Int32, time: Double) {
        
        if calculation == nil {
            calculation = Calculation()
        }
        let fetchRequest : NSFetchRequest<Calculation> = Calculation.fetchRequest()
        do {
            let results = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)

            if let calculation = calculation {
                calculation.name = Int16(results.count)
                calculation.maxNumber = maxNumber
                calculation.time = time
                for number in numbers {
                    let primeNumber = PrimeNumbers()
                    primeNumber.number = number
                    calculation.addToPrimeNumbers(primeNumber)
                }
                CoreDataManager.sharedManager.saveContext()
            }
        } catch let error {
            print("\(error)")
        }
        calculation = nil
    }
    
    func calculatePrimeNumbers(clouser: @escaping (_ time: Double, _ numbers: [Int32], _ maxNumber: Int32 ) -> ()) {
        
        let timer = MyTimer()
        let queue = DispatchQueue.global(qos: .utility)
        var primeNumbers = [Int32]()
        var maxResultNumber: Int?
        
        if let number = Int(self.numberTextField.text!) {

            let fetchRequest : NSFetchRequest<Calculation> = Calculation.fetchRequest()
            let predicate = NSPredicate(format: "%K < %i", "maxNumber", number)
            
            let sortDescriptor = NSSortDescriptor(key: "maxNumber", ascending: true)
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                let calcResults = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)
                if let max = calcResults.last {
                    maxResultNumber = Int(max.maxNumber)
                    let calcFetchRequest : NSFetchRequest<PrimeNumbers> = PrimeNumbers.fetchRequest()
                    let calcPredicate = NSPredicate(format: "%K == %i", "calculation.name", (calcResults.last?.name)!)
                    let calcSortDescriptor = NSSortDescriptor(key: "number", ascending: true)
                    calcFetchRequest.predicate = calcPredicate
                    calcFetchRequest.sortDescriptors = [calcSortDescriptor]
                    do {
                        let calcResults = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(calcFetchRequest)
                        for rez in calcResults {
                            primeNumbers.append(rez.number)
                        }
                    } catch let error {
                        print("\(error)")
                    }
                } else {
                    maxResultNumber = 0
                }
            } catch let error {
                print("\(error)")
            }

            queue.async {
                for i in maxResultNumber!..<number {
                    DispatchQueue.main.async {
                        self.updateProgressViewWith(number: number)
                    }
                    if self.isPrime(i) {
                        primeNumbers.append(Int32(i))
                    }
                }
                DispatchQueue.main.async {
                    self.progressView.progress = 0
                    self.progressView.isHidden = true
                    self.resultLabel.text = "Время выполнения:\(timer.stop())\nСписок чисел: \(primeNumbers)"
                    clouser(Double(timer.duration!), primeNumbers, Int32(number))
                }
            }
        }
    }

    // MARK: - Actions
    
    @objc private func calculationAction(sender: UIButton) {
        calculatePrimeNumbers { (time, primeNumbers, maxNumber) in
            self.saveCalculationWith(numbers: primeNumbers, maxNumber: maxNumber, time: time)
        }
    }

    @objc private func memoryClearAction(_ sender: UIBarButtonItem) {
        let fetchRequest : NSFetchRequest<Calculation> = Calculation.fetchRequest()
        do {
            let results = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)
            for result in results {
                CoreDataManager.sharedManager.persistentContainer.viewContext.delete(result)
            }
            CoreDataManager.sharedManager.saveContext()
        } catch let error {
            print("\(error)")
        }
    }
    
    @objc private func showResultsAction(_ sender: UIBarButtonItem) {
        let vc = ResultTableViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - ResultTableViewControllerDelegate
    
    func returnCalculationResult(numbers: [Int32], maxNUmber: Int32, time: Double) {
        self.resultLabel.text = "Время выполнения:\(String(format: "%.6f", time))\nСписок чисел: \(numbers)"
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}

