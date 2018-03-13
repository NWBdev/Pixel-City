//
//  PopVC.swift
//  Pixel-City
//
//  Created by Nathaniel Burciaga on 3/9/18.
//  Copyright © 2018 Nathaniel Burciaga. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    //Outlets
    @IBOutlet weak var popImageView: UIImageView!
    
    //Variables
    var passedImage: UIImage!
    var passedlbl: String!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }
    
    func initLbl(label: String){
        self.passedlbl = label
        print("testing Init Label: \(self.passedlbl)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        popImageView.image = passedImage
        descriptionLbl.text = passedlbl
        //dismiss PopView
        addDoubleTap()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func addDoubleTap() {
        let doubleTap =  UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
