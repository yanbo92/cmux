import CmuxAgentChat
import CmuxMobileBrowser
import CmuxMobileShell
import CmuxMobileShellModel
import CmuxMobileSupport
import Foundation
import SwiftUI

#if os(iOS) && DEBUG
struct WorkspaceDetailDelayedTerminalPreviewView: View {
    private static let workspaceID = MobileWorkspacePreview.ID(rawValue: "workspace-delayed-terminal")
    private static let terminalID = MobileTerminalPreview.ID(rawValue: "terminal-delayed")
    private static let deckBuildID = MobileTerminalPreview.ID(rawValue: "deck-build")
    private static let longWorkspaceTitle = "Extremely Long Workspace Title That Should Truncate Before Toolbar Buttons Overflow"
    private static let longTerminalTitle = "Long Agent Session Subtitle That Should Also Truncate First"

    @State private var store = MobileShellComposite(
        isSignedIn: true,
        connectionState: .connected,
        connectedHostName: "UI Test Mac",
        workspaces: initialWorkspaces
    )
    @State private var browserStore = BrowserSurfaceStore()
    @State private var didStartFixture = false

    var body: some View {
        WorkspaceShellView(
            store: store,
            signOut: {},
            showAddDevice: nil
        )
        .environment(browserStore)
        .task {
            guard !didStartFixture else { return }
            didStartFixture = true
            store.selectedWorkspaceID = Self.workspaceID
            if Self.usesSurfaceDeckPreview {
                store.selectedTerminalID = Self.deckBuildID
                return
            }
            if Self.usesRefreshingTerminalMenu {
                store.selectedTerminalID = Self.refreshingTerminalID(0)
                for generation in 1...80 {
                    try? await ContinuousClock().sleep(for: .milliseconds(250))
                    guard !Task.isCancelled else { return }
                    store.replaceForegroundWorkspaceState([Self.refreshingWorkspace(generation: generation)])
                    store.selectedWorkspaceID = Self.workspaceID
                }
                return
            }

            try? await ContinuousClock().sleep(for: .milliseconds(1_500))
            guard !Task.isCancelled else { return }
            let workspace = MobileWorkspacePreview(
                id: Self.workspaceID,
                name: Self.workspaceTitle,
                terminals: [
                    MobileTerminalPreview(id: Self.terminalID, name: Self.terminalTitle),
                ]
            )
            store.replaceForegroundWorkspaceState([workspace])
            store.selectedWorkspaceID = Self.workspaceID
            store.selectedTerminalID = Self.terminalID
            if Self.showsChatToggle {
                store.rememberChatSessions(
                    [
                        ChatSessionDescriptor(
                            id: "preview-chat-session",
                            agentKind: .claude,
                            title: "Preview Agent",
                            workspaceID: Self.workspaceID.rawValue,
                            terminalID: Self.terminalID.rawValue,
                            state: .working(since: Date()),
                            lastActivityAt: Date()
                        ),
                    ],
                    workspaceID: Self.workspaceID.rawValue
                )
            }
        }
    }

    private static var usesLongTitle: Bool {
        ProcessInfo.processInfo.environment["CMUX_UITEST_WORKSPACE_DETAIL_LONG_TITLE"] == "1"
    }

    private static var showsChatToggle: Bool {
        ProcessInfo.processInfo.environment["CMUX_UITEST_WORKSPACE_DETAIL_CHAT_TOGGLE"] == "1"
    }

    private static var usesRefreshingTerminalMenu: Bool {
        UITestConfig.workspaceDetailRefreshingTerminalMenuPreviewEnabled
    }

    private static var usesSurfaceDeckPreview: Bool {
        UITestConfig.workspaceSurfaceDeckPreviewEnabled
    }

    private static var workspaceTitle: String {
        usesLongTitle ? longWorkspaceTitle : "New Workspace"
    }

    private static var terminalTitle: String {
        usesLongTitle ? longTerminalTitle : "Terminal 1"
    }

    private static var initialWorkspaces: [MobileWorkspacePreview] {
        if usesSurfaceDeckPreview {
            return [surfaceDeckWorkspace]
        }
        if usesRefreshingTerminalMenu {
            return [refreshingWorkspace(generation: 0)]
        }
        return [
            MobileWorkspacePreview(
                id: workspaceID,
                name: workspaceTitle,
                terminals: []
            ),
        ]
    }

    private static var surfaceDeckWorkspace: MobileWorkspacePreview {
        let build = MobileTerminalPreview(id: deckBuildID, name: "Build & Typecheck")
        let model = MobileTerminalPreview(id: "deck-model", name: "Codex: Pane model")
        let simulator = MobileTerminalPreview(id: "deck-simulator", name: "iOS Simulator")
        let logs = MobileTerminalPreview(id: "deck-logs", name: "Live Logs")
        let api = MobileTerminalPreview(id: "deck-api", name: "Web API")
        return MobileWorkspacePreview(
            id: workspaceID,
            name: "Pane Deck Lab",
            terminals: [build, model, simulator, logs, api],
            paneLayout: MobileWorkspacePaneLayout(
                root: .split(
                    MobileWorkspaceSplitPreview(
                        id: "deck-root",
                        axis: .horizontal,
                        fraction: 0.58,
                        first: .pane(
                            MobileWorkspacePanePreview(
                                id: "deck-left",
                                terminalIDs: [build.id, model.id],
                                selectedTerminalID: build.id,
                                isFocused: true
                            )
                        ),
                        second: .split(
                            MobileWorkspaceSplitPreview(
                                id: "deck-right",
                                axis: .vertical,
                                fraction: 0.46,
                                first: .pane(
                                    MobileWorkspacePanePreview(
                                        id: "deck-top-right",
                                        terminalIDs: [simulator.id],
                                        selectedTerminalID: simulator.id
                                    )
                                ),
                                second: .pane(
                                    MobileWorkspacePanePreview(
                                        id: "deck-bottom-right",
                                        terminalIDs: [logs.id, api.id],
                                        selectedTerminalID: logs.id
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    }

    private static func refreshingWorkspace(generation: Int) -> MobileWorkspacePreview {
        MobileWorkspacePreview(
            id: workspaceID,
            name: "Terminal refresh fixture",
            terminals: (0...24).map { index in
                let baseName = index == 0 ? "Build" : String(format: "Terminal %02d", index)
                return MobileTerminalPreview(
                    id: refreshingTerminalID(index),
                    name: "\(baseName) refresh \(generation)"
                )
            }
        )
    }

    private static func refreshingTerminalID(_ index: Int) -> MobileTerminalPreview.ID {
        index == 0 ? "terminal-build" : MobileTerminalPreview.ID(rawValue: "terminal-extra-\(index)")
    }
}
#endif
