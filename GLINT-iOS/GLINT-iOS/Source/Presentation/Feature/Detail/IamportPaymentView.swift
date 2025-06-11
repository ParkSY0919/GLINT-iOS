//
//  IamportPaymentView.swift
//  GLINT-iOS
//
//  Created by 박신영 on 6/11/25.
//

import SwiftUI

import iamport_ios

struct IamportPaymentView: UIViewControllerRepresentable {
    let orderData: CreateOrderEntity.Response
    let filterData: FilterModel
    let onComplete: (IamportResponse?) -> Void
    
    func makeUIViewController(context: Context) -> IamportPaymentViewController {
        let viewController = IamportPaymentViewController(orderData: orderData, filterData: filterData)
        viewController.onComplete = self.onComplete
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: IamportPaymentViewController, context: Context) {}
}

final class IamportPaymentViewController: UIViewController {
    let orderData: CreateOrderEntity.Response
    let filterData: FilterModel
    var onComplete: ((IamportResponse?) -> Void)?
    
    init(orderData: CreateOrderEntity.Response, filterData: FilterModel) {
        self.orderData = orderData
        self.filterData = filterData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestIamportPayment()
    }
    
    func requestIamportPayment() {
        let userCode = "imp14511373" // slp 식별코드
        Task {
            let payment = await createPaymentData()
            
            print("payment: \(payment)")
            
            let response = await withCheckedContinuation { continuation in
                // UI 작업은 반드시 메인 스레드에서 실행해야 합니다.
                DispatchQueue.main.async {
                    Iamport.shared.payment(
                        viewController: self,
                        userCode: userCode,
                        payment: payment) { response in
                            print("결제 결과: \(String(describing: response))")
                            continuation.resume(returning: response)
                        }
                }
            }
            self.onComplete?(response)
        }
    }
    
    func createPaymentData() async -> IamportPayment {
        return IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: orderData.orderCode,
            amount: "\(filterData.price ?? 0)"
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = filterData.title
            $0.buyer_name = "박신영" // 실제 사용자 이름으로 변경
            $0.app_scheme = "sesac"
        }
    }
}
