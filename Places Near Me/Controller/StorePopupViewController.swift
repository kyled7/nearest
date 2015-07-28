//
//  StorePopupViewController.swift
//  Places Near Me
//
//  Created by Kyle Dinh on 7/5/15.
//  Copyright (c) 2015 Kyle Dinh. All rights reserved.
//

import UIKit
import QuartzCore
import StoreKit

class StorePopupViewController: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    @IBOutlet weak var popUpView: UIView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var product_id: NSString?;
    
    override func viewDidLoad() {
        product_id = "kyledinh_PlacesNearMe_Adsfree";
        super.viewDidLoad()
        
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.popUpView.layer.cornerRadius = 5
        self.popUpView.layer.shadowOpacity = 0.8
        self.popUpView.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        println(self.view.frame)
        println(self.popUpView.frame)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func requestAdsFree(sender: AnyObject) {
        if (SKPaymentQueue.canMakePayments()) {
            var productID:NSSet = NSSet(object: self.product_id!);
            var productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>);
            productsRequest.delegate = self;
            productsRequest.start();
            println("Fething Products");
        }
        else {
            println("User cannot make payments due to parental controls")
        }
    }
    
    func buyProduct(product: SKProduct){
        println("Sending the Payment Request to Apple");
        var payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addPayment(payment);
        
    }
    
    func productsRequest (request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var count : Int = response.products.count
        if (count>0) {
            var validProducts = response.products
            var validProduct: SKProduct = response.products[0] as! SKProduct
            if (validProduct.productIdentifier == self.product_id) {
                println(validProduct.localizedTitle)
                println(validProduct.localizedDescription)
                println(validProduct.price)
                buyProduct(validProduct);
            } else {
                println(validProduct.productIdentifier)
            }
        } else {
            println("nothing")
        }
    }
    
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        println("Error Fetching product information");
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
        println("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .Purchased:
                    println("Product Purchased");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    defaults.setBool(true , forKey: "adsRemoved")
                    
                    break;
                case .Failed:
                    println("Purchased Failed");
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .Restored:
                    println("Already Purchased");
                    SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
        
    }
    
    
    func showInView(aView: UIView!, animated: Bool)
    {
        aView.addSubview(self.view)
        if animated
        {
            self.showAnimate()
        }
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransformMakeScale(0.3, 0.3)
        self.view.alpha = 0.0;
        UIView.animateWithDuration(0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransformMakeScale(1.0, 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animateWithDuration(0.25, animations: {
            self.view.transform = CGAffineTransformMakeScale(0.3, 0.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    @IBAction func closePopup(sender: AnyObject) {
        self.removeAnimate()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
