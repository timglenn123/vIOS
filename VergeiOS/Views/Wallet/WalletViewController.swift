//
//  WalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 31-07-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit
import SwiftyJSON

class WalletViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var xvgBalanceLabel: UILabel!
    @IBOutlet weak var pairBalanceLabel: UILabel!
    @IBOutlet weak var pairSymbolBalanceLabel: UILabel!
    @IBOutlet weak var xvgPairBalanceLabel: UILabel!
    @IBOutlet weak var xvgPairSymbolLabel: UILabel!
    @IBOutlet weak var walletSlideScrollView: UIScrollView!
    @IBOutlet weak var walletSlidePageControl: UIPageControl!
    
    var walletSlides: [WalletSlideView] = []

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        xvgBalanceLabel.text = WalletManager.default.amount.toCurrency(currency: "XVG")
        
        self.setupSlides()
        self.setStats()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStats(notification:)),
            name: .didReceiveStats,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupSlides() {
        self.walletSlideScrollView.delegate = self
        self.walletSlides = self.createWalletSlides()
        
        DispatchQueue.main.async {
            self.setupWalletSlideScrollView()
            
            for slide in self.walletSlides {
                self.walletSlideScrollView.addSubview(slide)
            }
        }
    }
    
    
    // MARK: - Wallet Scroll View
    
    func createWalletSlides() -> [WalletSlideView] {
        let transactionsSlide = Bundle.main.loadNibNamed("TransactionsWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        let chartSlide = Bundle.main.loadNibNamed("SummaryWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        let summarySlide = Bundle.main.loadNibNamed("ChartWalletSlideView", owner: self, options: nil)?.first as! WalletSlideView
        
        return [
            transactionsSlide,
            chartSlide,
            summarySlide
        ]
    }
    
    func setupWalletSlideScrollView() {
        walletSlideScrollView.contentSize = CGSize(
            width: walletSlideScrollView.frame.width * CGFloat(walletSlides.count),
            height: walletSlideScrollView.frame.height
        )
        
        for i in 0 ..< walletSlides.count {
            let slideX = walletSlideScrollView.frame.width * CGFloat(i)
            let slideWidth = walletSlideScrollView.frame.width
            
            walletSlides[i].frame = CGRect(
                x: slideX,
                y: 0,
                width: slideWidth,
                height: walletSlideScrollView.frame.height
            )
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == walletSlideScrollView) {
            let currentPage = Int(round(walletSlideScrollView.contentOffset.x/walletSlideScrollView.frame.width))
            self.walletSlidePageControl.currentPage = currentPage
        }
    }

    @objc func deviceRotated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupWalletSlideScrollView()
        }
    }
    
    @objc func didReceiveStats(notification: Notification? = nil) {
        self.setStats()
    }
    
    func setStats() {
        DispatchQueue.main.async {
            if let xvgInfo = PriceTicker.shared.xvgInfo {
                let walletAmount = WalletManager.default.amount
                self.pairBalanceLabel.text = NSNumber(value: walletAmount.doubleValue * xvgInfo.raw.price).toCurrency()
                self.pairSymbolBalanceLabel.text = "\(WalletManager.default.currency) BALANCE"
                
                self.xvgPairBalanceLabel.text = xvgInfo.display.price
                self.xvgPairSymbolLabel.text = "\(WalletManager.default.currency)/XVG"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TransactionTableViewController" {
            if let nc = segue.destination as? UINavigationController {
                if let vc = nc.viewControllers.first as? TransactionTableViewController {
                    vc.transaction = sender as? Transaction
                }
            }
        }
    }
}
