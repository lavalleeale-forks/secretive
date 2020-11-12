import Foundation
import Combine
import AppKit

protocol AgentStatusCheckerProtocol: ObservableObject {
    var running: Bool { get }
}

class AgentStatusChecker: ObservableObject, AgentStatusCheckerProtocol {

    @Published var running: Bool = false
    @Published var otherVersionsRunning: [NSRunningApplication] = []

    init() {
        check()
    }

    func check() {
        running = instanceSecretAgentProcess != nil
        otherVersionsRunning = otherVerisonsAgentProcesses
    }

    // All processes, including ones from older versions, etc
    var secretAgentProcesses: [NSRunningApplication] {
        NSRunningApplication.runningApplications(withBundleIdentifier: Constants.secretAgentAppID)
    }

    // The process corresponding to this instance of Secretive
    var instanceSecretAgentProcess: NSRunningApplication? {
        let agents = secretAgentProcesses
        for agent in agents {
            guard let url = agent.bundleURL else { continue }
            if url.absoluteString.hasPrefix(Bundle.main.bundleURL.absoluteString) {
                return agent
            }
        }
        return nil
    }

    var otherVerisonsAgentProcesses: [NSRunningApplication] {
        let all = secretAgentProcesses
        let ours = instanceSecretAgentProcess
        return all.filter { $0 != ours }
    }

}

extension AgentStatusChecker {

    enum Constants {
        static let secretAgentAppID = "com.maxgoedjen.Secretive.SecretAgent"
    }

}
