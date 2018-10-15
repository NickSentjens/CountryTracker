//
//  CountriesCell.swift
//  CountryTracker
//
//  Created by Nick Sentjens on 2018-10-11.
//  Copyright © 2018 NickSentjens. All rights reserved.
//

import Foundation
import UIKit

class CountryCell: UITableViewCell {
    let nameLabel = UILabel()
    let populationLabel = UILabel()
    let capitalLabel = UILabel()
    let flagImageView = UIImageView()
    let favouriteButton = UIButton()
    
    static let reuseIdentifier = "CountryCell"
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(populationLabel)
        contentView.addSubview(capitalLabel)
        contentView.addSubview(flagImageView)
        contentView.addSubview(favouriteButton)
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        flagImageView.translatesAutoresizingMaskIntoConstraints = false
        favouriteButton.translatesAutoresizingMaskIntoConstraints = false
        capitalLabel.translatesAutoresizingMaskIntoConstraints = false
        populationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            flagImageView.widthAnchor.constraint(equalToConstant: 40),
            flagImageView.heightAnchor.constraint(equalToConstant: 40),
            flagImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            flagImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: flagImageView.trailingAnchor, constant: 16),
            
            populationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            populationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            
            capitalLabel.leadingAnchor.constraint(equalTo: populationLabel.leadingAnchor),
            capitalLabel.topAnchor.constraint(equalTo: populationLabel.bottomAnchor, constant: 6),
            
            favouriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favouriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

