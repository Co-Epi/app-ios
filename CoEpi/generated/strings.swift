// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Alerts {
    /// Alerts
    internal static let title = L10n.tr("Localizable", "alerts.title")
    internal enum Count {
      /// no new contact alerts
      internal static let `none` = L10n.tr("Localizable", "alerts.count.none")
      /// 1 new contact alert
      internal static let one = L10n.tr("Localizable", "alerts.count.one")
      /// %d new contact alerts
      internal static func some(_ p1: Int) -> String {
        return L10n.tr("Localizable", "alerts.count.some", p1)
      }
    }
  }

  internal enum Healthquiz {
    /// SUBMIT
    internal static let submit = L10n.tr("Localizable", "healthquiz.submit")
    /// Are you experiencing any of the following symptoms?
    internal static let symptomQuestion = L10n.tr("Localizable", "healthquiz.symptomQuestion")
    /// My Health
    internal static let title = L10n.tr("Localizable", "healthquiz.title")
  }

  internal enum Home {
    /// Share
    internal static let share = L10n.tr("Localizable", "home.share")
    internal enum ContactAlerts {
      /// SEE ALERTS
      internal static let button = L10n.tr("Localizable", "home.contactAlerts.button")
      /// Approximate times that you may have been exposed to a symptomatic individual
      internal static let description = L10n.tr("Localizable", "home.contactAlerts.description")
      /// Contact Alerts
      internal static let title = L10n.tr("Localizable", "home.contactAlerts.title")
    }
    internal enum Footer {
      /// Build
      internal static let build = L10n.tr("Localizable", "home.footer.build")
      /// Debug
      internal static let debug = L10n.tr("Localizable", "home.footer.debug")
      /// Version
      internal static let version = L10n.tr("Localizable", "home.footer.version")
    }
    internal enum MyHealth {
      /// CHECK-IN
      internal static let button = L10n.tr("Localizable", "home.myHealth.button")
      /// Monitor your health and report symptoms
      internal static let description = L10n.tr("Localizable", "home.myHealth.description")
      /// My Health
      internal static let title = L10n.tr("Localizable", "home.myHealth.title")
    }
  }

  internal enum Onboarding {
    /// GET STARTED
    internal static let getStarted = L10n.tr("Localizable", "onboarding.getStarted")
    /// How your data is used
    internal static let howDataUsed = L10n.tr("Localizable", "onboarding.howDataUsed")
    /// Collaborate. Inform. Protect.
    internal static let logo = L10n.tr("Localizable", "onboarding.logo")
    internal enum Alerts {
      ///  about possible exposure to infectious illness
      internal static let afterBold = L10n.tr("Localizable", "onboarding.alerts.afterBold")
      /// Get 
      internal static let beforeBold = L10n.tr("Localizable", "onboarding.alerts.beforeBold")
      /// contextualized alerts
      internal static let bold = L10n.tr("Localizable", "onboarding.alerts.bold")
    }
    internal enum Monitor {
      ///  your health
      internal static let afterBold = L10n.tr("Localizable", "onboarding.monitor.afterBold")
      /// 
      internal static let beforeBold = L10n.tr("Localizable", "onboarding.monitor.beforeBold")
      /// Monitor
      internal static let bold = L10n.tr("Localizable", "onboarding.monitor.bold")
    }
    internal enum Track {
      ///  where you've been
      internal static let afterBold = L10n.tr("Localizable", "onboarding.track.afterBold")
      /// 
      internal static let beforeBold = L10n.tr("Localizable", "onboarding.track.beforeBold")
      /// Track
      internal static let bold = L10n.tr("Localizable", "onboarding.track.bold")
    }
  }

  internal enum Symptom {
    /// Diarrhea
    internal static let diarrhea = L10n.tr("Localizable", "symptom.diarrhea")
    /// Difficulty breathing
    internal static let difficultyBreathing = L10n.tr("Localizable", "symptom.difficultyBreathing")
    /// Dry cough
    internal static let dryCough = L10n.tr("Localizable", "symptom.dryCough")
    /// Fever
    internal static let fever = L10n.tr("Localizable", "symptom.fever")
    /// Loss of smell/taste
    internal static let lossOfSmellTaste = L10n.tr("Localizable", "symptom.lossOfSmellTaste")
    /// Muscle aches
    internal static let muscleAches = L10n.tr("Localizable", "symptom.muscleAches")
    /// Nasal congestion
    internal static let nasalCongestion = L10n.tr("Localizable", "symptom.nasalCongestion")
    /// None of the above
    internal static let `none` = L10n.tr("Localizable", "symptom.none")
    /// Runny nose
    internal static let runnyNose = L10n.tr("Localizable", "symptom.runnyNose")
    /// Sore throat
    internal static let soreThroat = L10n.tr("Localizable", "symptom.soreThroat")
    /// Tiredness
    internal static let tiredness = L10n.tr("Localizable", "symptom.tiredness")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    // swiftlint:disable:next nslocalizedstring_key
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
