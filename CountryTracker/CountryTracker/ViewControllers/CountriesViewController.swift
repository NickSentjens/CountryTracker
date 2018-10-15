//
//  CountriesViewController.swift
//  CountryTracker
//
//  Created by Nick Sentjens on 2018-10-11.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import UIKit
import CoreData


class CountriesViewController: UIViewController  {
    private var tableView: UITableView = UITableView()
    private var searchTextField: UITextField = UITextField()
    
    private var countries: [Country] = []
    private var favoritedCountries: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Country"
        
        setUpTextField()
        setUpTableView()
    }
    
    private func setUpTextField() {
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.placeholder = "Search for country"
        searchTextField.delegate = self
        searchTextField.font = UIFont.systemFont(ofSize: 15)
        searchTextField.borderStyle = UITextBorderStyle.roundedRect
        searchTextField.returnKeyType = UIReturnKeyType.done
        
        view.addSubview(searchTextField)
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: 60),
            ])
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(CountryCell.self, forCellReuseIdentifier: "CountryCell")
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 150 / 225,
                                            green: 191 / 225,
                                            blue: 72 / 225,
                                            alpha: 1)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
    }
    
    private func fetchListFor(_ searchString: String) {
        guard let networkCallURL = URL(string: "https://restcountries.eu/rest/v2/name/" + searchString) else {
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        
        let task = session.dataTask(with: networkCallURL) { data, response, error in
            if error == nil {
                if let data = data,
                    let countries = try? JSONDecoder().decode([Country].self, from: data) {
                    self.countries = countries
                    self.tableView.reloadData()
                } else {
                    //failed to decode data
                }
            }
        }
        
        task.resume()
    }
    
    private func save(country: Country) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext

        guard let entity = NSEntityDescription.entity(forEntityName: "CountryModel",
                                                      in: managedContext) else {
                                                        return
        }
        
        let countryObject = NSManagedObject(entity: entity,
                                            insertInto: managedContext)
        
        countryObject.setValue(country.population, forKeyPath: "population")
        countryObject.setValue(country.capital, forKey: "capital")
        countryObject.setValue(country.flagURL.absoluteString, forKey: "flagURL")
        countryObject.setValue(country.name, forKey: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension CountriesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell") as? CountryCell else {
            return UITableViewCell()
        }
        let country = countries[indexPath.row]
        cell.nameLabel.text = country.name
        cell.populationLabel.text = "Population: " + String(country.population)
        cell.capitalLabel.text = "Capital: " + String(country.capital)
        
        if country.isFavorited {
            cell.favouriteButton.setImage(UIImage(named: "goldStar.png"), for: .normal)
        }
        else {
            cell.favouriteButton.setImage(UIImage(named: "star.png"), for: .normal)
        }
        
        DispatchQueue.global().async {
            let flag = try? Data(contentsOf: country.flagURL)
            DispatchQueue.main.async {
                if let flag = flag {
                    // endpoint is returning a .svg file, would have to use an external lib
                    cell.flagImageView.image = UIImage(data: flag)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var country = countries[indexPath.row]
        country.isFavorited = !country.isFavorited
        if country.isFavorited {
            self.save(country: country)
        }
        countries[indexPath.row] = country
        tableView.reloadData()
    }
}

extension CountriesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let country = textField.text {
            self.fetchListFor(country)
        }
    }
}
