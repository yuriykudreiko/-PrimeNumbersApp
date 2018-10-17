//
//  ResultTableViewController.swift
//  GURTAM_TEST
//
//  Created by Yra on 16.10.2018.
//  Copyright © 2018 Yuriy Kudreika. All rights reserved.
//

import UIKit
import CoreData

protocol ResultTableViewControllerDelegate {
    func returnCalculationResult(numbers: [Int32], maxNUmber: Int32, time: Double)
}

class ResultTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var delegate : ResultTableViewControllerDelegate?
    fileprivate lazy var fetchedResultsController = CoreDataManager.sharedManager.fetchedResultsController(entityName: "Calculation", keyForSort: "name") as! NSFetchedResultsController<Calculation>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let calculation = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(calculation.name)) 0...\(calculation.maxNumber), time: \(String(format: "%.6f", calculation.time))"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let calculation = fetchedResultsController.object(at: indexPath)
        let fetchRequest : NSFetchRequest<PrimeNumbers> = PrimeNumbers.fetchRequest()
        let predicate = NSPredicate(format: "%K == %i", "calculation.name", calculation.name)
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let results = try CoreDataManager.sharedManager.persistentContainer.viewContext.fetch(fetchRequest)
            var returnResult = [Int32]()
            var isWrite = false
            var maxNumber: Int32 = 0
            var time: Double = 0
            
            for result in results {
                returnResult.append(result.number)
                if !isWrite {
                    maxNumber = (result.calculation?.maxNumber)!
                    time = (result.calculation?.time)!
                } else {
                    isWrite = true
                }
            }
            self.delegate?.returnCalculationResult(numbers: returnResult, maxNUmber: maxNumber, time: time)
            self.navigationController?.popToRootViewController(animated: true)
        } catch let error {
            print("\(error)")
        }
    }
}
