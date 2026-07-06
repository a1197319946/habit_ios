import Foundation
import CloudKit
import SwiftUI

class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()
    
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var statusMessage: String = ""
    
    private init() {
        checkAccountStatus()
    }
    
    func checkAccountStatus(completion: ((CKAccountStatus) -> Void)? = nil) {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.accountStatus = status
                switch status {
                case .available:
                    self?.statusMessage = "iCloud 账号正常连接"
                case .noAccount:
                    self?.statusMessage = "未登录，请在系统设置中登录您的 Apple ID"
                case .restricted:
                    self?.statusMessage = "iCloud 访问受限"
                case .couldNotDetermine:
                    self?.statusMessage = "无法确定 iCloud 状态"
                case .temporarilyUnavailable:
                    self?.statusMessage = "iCloud 服务暂不可用"
                @unknown default:
                    self?.statusMessage = "未知状态"
                }
                completion?(status)
            }
        }
    }
}
