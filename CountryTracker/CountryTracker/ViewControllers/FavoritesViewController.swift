//
//  FavoritesViewController.swift
//  CountryTracker
//
//  Created by Nick Sentjens on 2018-10-13.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    private var tableView =  UITableView()
    
    private var persistentContainer: NSPersistentContainer?
    private var fetchedResultsController: NSFetchedResultsController<CountryModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Favourites"
        self.setUpFetchResultsController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.setUpTableView()
        
        do {
            try self.fetchedResultsController?.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try persistentContainer?.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    private func setUpFetchResultsController() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.persistentContainer = appDelegate.persistentContainer
            
            // Create Fetch Request
            let fetchRequest: NSFetchRequest<CountryModel> = CountryModel.fetchRequest()
            
            // Configure Fetch Request
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            // Create Fetched Results Controller
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer!.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            
            // Configure Fetched Results Controller
            fetchedResultsController.delegate = self
            
            self.fetchedResultsController = fetchedResultsController
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(CountryCell.self, forCellReuseIdentifier: "CountryCell")
        tableView.backgroundColor = UIColor(red: 150 / 225,
                                            green: 191 / 225,
                                            blue: 72 / 225,
                                            alpha: 1)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 150 / 225,
                                            green: 191 / 225,
                                            blue: 72 / 225,
                                            alpha: 1)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
}

extension FavoritesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let countries = fetchedResultsController?.fetchedObjects else { return 0 }
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") as? CountryCell, let country = fetchedResultsController?.object(at: indexPath) else {
            return UITableViewCell()
        }
        
        
        cell.nameLabel.text = country.name
        cell.populationLabel.text = "Population: " + String(country.population)

        cell.capitalLabel.text = "Capital: " + (country.capital ?? "")
        
        cell.favouriteButton.isHidden = true

        if let flagString = country.flagURL, let flagURL = URL(string: flagString) {
            DispatchQueue.global().async {
                let flag = try? Data(contentsOf: flagURL)
                DispatchQueue.main.async {
                    if let flag = flag {
                        // endpoint is returning a .svg file, would have to use an external lib
                        cell.flagImageView.image = UIImage(data: flag)
                    }
                }
            }

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
}

extension FavoritesViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("...")
        }
    }
    
}
