//
//  LoadingView.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//
import UIKit
import SnapKit
class LoadingVC: BaseVC{
    var loadingAlertView: UIAlertController?
    var loadingProgressView: UIProgressView?
    func presentLoadingAlert(title:String? = "Please wait",message:String?,cancelAction:@escaping ()->()){
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.loadingAlertView = alertView
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] _ in
            self?.loadingAlertView?.dismiss(animated: true){
                self?.loadingAlertView = nil
                self?.loadingProgressView = nil
                cancelAction()
            }
        }))
        present(alertView, animated: true, completion: {
            //  Add your progressbar after alert is shown (and measured)
            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: alertView.view.frame.width - margin * 2.0 , height: 2.0)
            self.loadingProgressView = UIProgressView(frame: rect)
            self.loadingProgressView?.progress = 0.0
            self.loadingProgressView?.tintColor = .tintColor
            alertView.view.addSubview(self.loadingProgressView!)
        })
    }
    func dismissLoadingAlert(completion:@escaping ()->()){
        loadingAlertView?.dismiss(animated: true){
            self.loadingProgressView = nil
            self.loadingAlertView = nil
            completion()
        }
    }
}
