//
//  IamportPaymentView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import SwiftUI

import iamport_ios

struct IamportPaymentView: UIViewControllerRepresentable {
    let paymentData: IamportPayment
    let onComplete: (IamportResponse?) -> Void
    
    func makeUIViewController(context: Context) -> IamportPaymentViewController {
        let viewController = IamportPaymentViewController(paymentData: paymentData)
        viewController.onComplete = self.onComplete
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: IamportPaymentViewController, context: Context) {}
}

final class IamportPaymentViewController: UIViewController {
    let paymentData: IamportPayment
    var onComplete: ((IamportResponse?) -> Void)?
    
    init(paymentData: IamportPayment) {
        self.paymentData = paymentData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestIamportPayment()
    }
    
    private func requestIamportPayment() {
        let userCode = Strings.Detail.Purchase.slpIdentiCode
        Task {
            let response = await withCheckedContinuation { continuation in
                DispatchQueue.main.async {
                    Iamport.shared.payment(
                        viewController: self,
                        userCode: userCode,
                        payment: self.paymentData) { response in
                            print("결제 결과: \(String(describing: response))")
                            continuation.resume(returning: response)
                        }
                }
            }
            self.onComplete?(response)
        }
    }
}
