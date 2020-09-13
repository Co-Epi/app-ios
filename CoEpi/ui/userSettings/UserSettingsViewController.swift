import Introspect
import SafariServices
import SwiftUI
import UIKit

class UserSettingsViewController: UIViewController, ObservableObject {
    private let viewModel: UserSettingsViewModel

    init(viewModel: UserSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = L10n.Settings.title
    }

    required init?(coder _: NSCoder) {
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

struct DateSelector: View {
    @ObservedObject var viewModel: UserSettingsViewModel
    @State var hours: String = "18"
    @State var minutes: String = "00"
    var body: some View {
        VStack {
            Spacer()
            Text("Input date and time")
            HStack {
                Spacer()
                TextField("Enter hours", text: $hours)
                    .multilineTextAlignment(.trailing)
                Text(":")
                TextField("minutes", text: $minutes)
                Spacer()
            }
            .padding([.leading, .trailing], 20)
            Text("Reminder time \(hours):\(minutes)")
            Spacer()
            Button("Save", action: {[viewModel] in
                log.d("Saving \(hours):\(minutes)", tags: .ui)
                viewModel.onReminderSave(hours: hours, minutes: minutes)
            })
            Spacer()
        }
    }
}

struct UserSettingsView: View {
    @ObservedObject var viewModel: UserSettingsViewModel
    @State var showingDateSelectorScreen = false
    weak var viewController: UserSettingsViewController?
    private let greyBGColor = UIColor(hex: "C4C4C4").withAlphaComponent(0.5)

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
            // TODO: not working
            tableView.separatorStyle = .none

            tableView.backgroundColor = greyBGColor
        }
    }

    private func view(setting: UserSettingViewData) -> some View {
        switch setting {
        case let .sectionHeader(title, text):
            return AnyView(sectionHeaderView(title: title, text: text))
        case let .toggle(text, value, id, hasBottomLine):
            return AnyView(toggleView(text: text, value: value, id: id,
                                      hasBottomLine: hasBottomLine))
        case let .link(text, url):
            return AnyView(linkView(text: text, url: url))
        case let .textAction(text, action):
            return AnyView(actionTextView(text: text, action: action))
        case let .text(text):
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
        .padding(.leading, 20).padding(.trailing, 20)
        .padding(.top, 8)
    }

    private func toggleView(text: String, value: Bool,
                            id: UserSettingToggleId,
                            hasBottomLine: Bool) -> some View {
        VStack {
            SettingsToggle(text: text, isToggled: value, onChange: { [viewModel] isOn in
                viewModel.onToggle(id: id, value: isOn)
            })
                .padding(.bottom, hasBottomLine ? 16 : 24).padding(.top, 16)
            if hasBottomLine {
                // TODO: use this when possible to hide default separators
//                Divider().background(Color.black)
            }
        }
        .padding(.leading, 20).padding(.trailing, 20)
    }

    private func linkView(text: String, url: URL) -> some View {
        Button(action: {
            viewController?.openWeb(url: url)
        }, label: {
            Text(text)
                .font(.system(size: 13))
        })
            .listRowBackground(Color(greyBGColor))
            .padding(.leading, 20).padding(.trailing, 20)
    }

    private func actionTextView(text: String, action: UserSettingActionId) -> some View {
        Button(action: {
            viewModel.onAction(id: action)
        }, label: {
            Text(text)
                .font(.system(size: 13))
        })
            .listRowBackground(Color(greyBGColor))
            .padding(.leading, 20).padding(.trailing, 20)
    }

    private func textView(text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .listRowBackground(Color(greyBGColor))
            .padding(.leading, 20).padding(.trailing, 20)
            .gesture(TapGesture(count: 3)
                .onEnded { _ in
                    log.d("tripple tap", tags: .ui)
                    self.showingDateSelectorScreen.toggle()
                }
            )
            .sheet(isPresented: $showingDateSelectorScreen, content: {DateSelector(viewModel: viewModel)})
    }
}

// TODO: generic
struct SettingsToggle: View {
    let text: String
    let onChange: (Bool) -> Void

    @State private var isToggled: Bool

    init(text: String, isToggled: Bool, onChange: @escaping (Bool) -> Void) {
        self.text = text
        self.onChange = onChange
        _isToggled = State(initialValue: isToggled)
    }

    var body: some View {
        Toggle(isOn: Binding(
            get: { isToggled },
            set: {
                isToggled = $0
                onChange($0)
            }
        )) {
            Text(text)
                .font(.system(size: 17))
                .fontWeight(.semibold)
        }
    }
}

struct UserSettingsViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
