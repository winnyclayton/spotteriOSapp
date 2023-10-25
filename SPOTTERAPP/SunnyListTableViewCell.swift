//
//  SunnyListTableViewCell.swift
//  SPOTTERAPP
//
//  Created by Winona Clayton on 23/6/2023.
//

import UIKit

class SunnyListTableViewCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblHours: UILabel!
    @IBOutlet weak var lblKlms: UILabel!
    @IBOutlet weak var expandIcon: UIImageView!
    @IBOutlet weak var lblRainfall: UILabel!
    @IBOutlet weak var lblPrecis: UILabel!
    @IBOutlet weak var lblWind: UILabel!
    @IBOutlet weak var lblHighTemp: UILabel!
    @IBOutlet weak var lblLowTemp: UILabel!
    @IBOutlet weak var sunnyListDirections: UIImageView!
    
    func rotateExpandIcon() {
            UIView.animate(withDuration: 0.3) {
                self.expandIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
        }

        func resetExpandIcon() {
            expandIcon.transform = CGAffineTransform.identity
        }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
