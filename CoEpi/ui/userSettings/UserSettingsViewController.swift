import UIKit
import SwiftUI
import SafariServices
import Introspect

class UserSettingsViewController: UIViewController, ObservableObject {
    private let viewModel: UserSettingsViewModel

    init(viewModel: UserSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = L10n.Settings.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setRootSwiftUIView(view: UserSettingsView(viewModel: viewModel,
                                                  viewController: self))
    }

    func openWeb(url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let vc = SFSafariViewController(url: url, configuration: config)
        present(vc, animated: true)
    }
}

struct UserSettingsView: View {
    @ObservedObject var viewModel: UserSettingsViewModel

    weak var viewController: UserSettingsViewController?

    init(viewModel: UserSettingsViewModel, viewController: UserSettingsViewController) {
        self.viewModel = viewModel
        self.viewController = viewController
    }

    var body: some View {
        List {
            ForEach(viewModel.settingsViewData) { setting in
                view(setting: setting.data)
            }
        }
        .introspectTableView { tableView in
            // TODO not working
            tableView.separatorStyle = .none
        }
        .padding(.leading, 20).padding(.trailing, 20).padding(.top, 8)
    }

    private func view(setting: UserSettingViewData) -> some View {
        switch setting {
        case .sectionHeader(let title, let text):
            return AnyView(sectionHeaderView(title: title, text: text))
        case .toggle(let text, let value, let id, let hasBottomLine):
            return AnyView(toggleView(text: text, value: value, id: id,
                                      hasBottomLine: hasBottomLine))
        case .link(let text, let url):
            return AnyView(linkView(text: text, url: url))
        case .textAction(let text, let action):
            return AnyView(actionTextView(text: text, action: action))
        case .text(let text):
            return AnyView(textView(text: text))
        }
    }

    private func sectionHeaderView(title: String, text: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.coEpiPurple))
            Text(text)
                .font(.system(size: 13))
                .fontWeight(.semibold)
                .padding(.bottom, 16)
        }
        .background(Color.white)
    }

    private func toggleView(text: String, value: Bool,
                            id: UserSettingToggleId,
                            hasBottomLine: Bool) -> some View {
        VStack {
            Toggle(isOn: Binding(
                get: { value },
                set: { viewModel.onToggle(id: id, value: $0) }
            )) {
                Text(text)
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
            }
            .padding(.bottom, hasBottomLine ? 16 : 24).padding(.top, 16)
            if hasBottomLine {
                // TODO use this when possible to hide default separators
//                Divider().background(Color.black)
            }
        }
    }

    private func linkView(text: String, url: URL) -> some View {
        Button(action: {
            viewController?.openWeb(url: url)
         }) {
             Text(text)
                .font(.system(size: 13))
         }
    }

    private func actionTextView(text: String, action: UserSettingActionId) -> some View {
        Button(action: {
            viewModel.onAction(id: action)
         }) {
             Text(text)
                .font(.system(size: 13))
         }
    }

    private func textView(text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
    }
}
