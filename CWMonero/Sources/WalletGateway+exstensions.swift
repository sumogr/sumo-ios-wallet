import Foundation
import CakeWalletLib

extension WalletGateway {
    public func makeConfigURL(for walletName: String) -> URL {
        let folderURL = makeDirURL(for: walletName)
        let filename = walletName + ".json"
        return folderURL.appendingPathComponent(filename)
    }
    
    public func makeURL(for walletName: String) -> URL {
        let folderURL = makeDirURL(for: walletName)
        return folderURL.appendingPathComponent(walletName)
    }
    
    public func makeDirURL(for walletName: String) -> URL {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: Self.path + "/" + walletName)
        }
        if !Self.path.isEmpty {
            url.appendPathComponent(Self.path)
        }
        url.appendPathComponent(walletName)
        var isDir: ObjCBool = true
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir.boolValue {
            return try! FileManager.default.createWalletDirectory(for: walletName)
        }
        
        return url
    }
}
