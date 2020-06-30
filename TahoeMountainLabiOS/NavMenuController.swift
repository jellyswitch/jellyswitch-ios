//
//  NavMenuController.swift
//  TahoeMountainLabiOS
//
//  Created by David Paola on 3/15/19.
//  Copyright © 2019 David Paola. All rights reserved.
//

import UIKit
import SwiftyJSON

struct NavItem {
    let title: String
    let path: URL
}

protocol NavMenuControllerDelegate {
    func navMenuController(_: NavMenuController, didSelectItem item: NavItem)
}

class NavMenuController: UITableViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var titleImage: UIImageView!
    
    var delegate: NavMenuControllerDelegate?
    var navItems: [NavItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = AppSettings.shared.sidebarTitle
        
        if AppSettings.shared.hasSidebarIcon {
            self.titleImage.isHidden = false
            self.titleLabel.isHidden = true
        } else {
            self.titleImage.isHidden = true
            self.titleLabel.isHidden = false
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let navItems = self.navItems else {
            return 0
        }
        
        return navItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavItemCell", for: indexPath)
        
        guard let navItems = self.navItems else {
            return cell
        }
        
        cell.textLabel?.text = navItems[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navItems = self.navItems else {
            return
        }
        
        self.delegate?.navMenuController(self, didSelectItem: navItems[indexPath.row])
    }
}
