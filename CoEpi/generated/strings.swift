// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Ux {
    /// days
    internal static let days = L10n.tr("Localizable", "UX.days")
    /// No
    internal static let no = L10n.tr("Localizable", "UX.no")
    /// Skip
    internal static let skip = L10n.tr("Localizable", "UX.skip")
    /// SUBMIT
    internal static let submit = L10n.tr("Localizable", "UX.submit")
    /// I don't know
    internal static let unknown = L10n.tr("Localizable", "UX.unknown")
    /// Yes
    internal static let yes = L10n.tr("Localizable", "UX.yes")
    internal enum Breathless {
      /// Follow up: Shortness of breath
      internal static let heading = L10n.tr("Localizable", "UX.breathless.heading")
      /// I am too short of breath to leave the house or I am short of breath when dressing
      internal static let p0 = L10n.tr("Localizable", "UX.breathless.p0")
      /// I stop for breath after walking about 100 yards or after a few minutes on level ground
      internal static let p1 = L10n.tr("Localizable", "UX.breathless.p1")
      /// On level ground, I have to stop for breath when walking at my own pace
      internal static let p2 = L10n.tr("Localizable", "UX.breathless.p2")
      /// I get short of breath when hurrying on level ground or walking up a slight hill
      internal static let p3 = L10n.tr("Localizable", "UX.breathless.p3")
      /// I only get short of breath with strenuous exercise
      internal static let p4 = L10n.tr("Localizable", "UX.breathless.p4")
      /// Select one option
      internal static let subtitle = L10n.tr("Localizable", "UX.breathless.subtitle")
      /// I feel short of breath when:
      internal static let title = L10n.tr("Localizable", "UX.breathless.title")
    }
    internal enum Cough {
      /// Felt worse and better throughout the day
      internal static let better = L10n.tr("Localizable", "UX.cough.better")
      /// Follow up: Cough
      internal static let heading = L10n.tr("Localizable", "UX.cough.heading")
      /// Stayed the same or felt steadily worse
      internal static let same = L10n.tr("Localizable", "UX.cough.same")
      /// Select one option
      internal static let subtitle3 = L10n.tr("Localizable", "UX.cough.subtitle3")
      /// \nMy throat feels 'tickly' or \n'scratchy' without mucus
      internal static let subtitleDry = L10n.tr("Localizable", "UX.cough.subtitleDry")
      /// \nIt feels like there is mucus \nin my throat and/or chest
      internal static let subtitleWet = L10n.tr("Localizable", "UX.cough.subtitleWet")
      /// I would describe my cough as:
      internal static let title1 = L10n.tr("Localizable", "UX.cough.title1")
      /// How many days have you been coughing?
      internal static let title2 = L10n.tr("Localizable", "UX.cough.title2")
      /// Today my cough has:
      internal static let title3 = L10n.tr("Localizable", "UX.cough.title3")
      /// Dry
      internal static let titleDry = L10n.tr("Localizable", "UX.cough.titleDry")
      /// Wet
      internal static let titleWet = L10n.tr("Localizable", "UX.cough.titleWet")
      /// Felt worse when I am outside
      internal static let worse = L10n.tr("Localizable", "UX.cough.worse")
    }
    internal enum Fever {
      /// Armpit
      internal static let armpit = L10n.tr("Localizable", "UX.fever.armpit")
      /// Cº
      internal static let c = L10n.tr("Localizable", "UX.fever.C")
      /// Ear
      internal static let ear = L10n.tr("Localizable", "UX.fever.ear")
      /// Fº
      internal static let f = L10n.tr("Localizable", "UX.fever.F")
      /// Follow up: Fever
      internal static let heading = L10n.tr("Localizable", "UX.fever.heading")
      /// Mouth
      internal static let mouth = L10n.tr("Localizable", "UX.fever.mouth")
      /// Other
      internal static let other = L10n.tr("Localizable", "UX.fever.other")
      /// How many days have you had a fever?
      internal static let title1 = L10n.tr("Localizable", "UX.fever.title1")
      /// Have you taken your temperature today?
      internal static let title2 = L10n.tr("Localizable", "UX.fever.title2")
      /// Where did you take your temperature most recently?
      internal static let title3 = L10n.tr("Localizable", "UX.fever.title3")
      /// What was the highest temperature reading today?
      internal static let title4 = L10n.tr("Localizable", "UX.fever.title4")
    }
    internal enum Home {
      /// Exposure Alerts
      internal static let alerts1 = L10n.tr("Localizable", "UX.home.alerts1")
      /// Review your potential exposures
      internal static let alerts2 = L10n.tr("Localizable", "UX.home.alerts2")
      /// new exposures detected
      internal static let detected = L10n.tr("Localizable", "UX.home.detected")
      /// How is my data being used?
      internal static let how = L10n.tr("Localizable", "UX.home.how")
      /// Symptom Reporting
      internal static let report1 = L10n.tr("Localizable", "UX.home.report1")
      /// Share how you are feeling
      internal static let report2 = L10n.tr("Localizable", "UX.home.report2")
      /// Share
      internal static let share = L10n.tr("Localizable", "UX.home.share")
      /// CoEpi
      internal static let title = L10n.tr("Localizable", "UX.home.title")
      internal enum Footer {
        /// Build
        internal static let build = L10n.tr("Localizable", "UX.home.footer.build")
        /// Debug
        internal static let debug = L10n.tr("Localizable", "UX.home.footer.debug")
        /// Version
        internal static let version = L10n.tr("Localizable", "UX.home.footer.version")
      }
    }
    internal enum Onboarding {
      /// CoEpi will anonymously log interactions with other devices using compatible apps.
      internal static let body1 = L10n.tr("Localizable", "UX.onboarding.body1")
      /// Share any symptoms you may have, when you notice them.
      internal static let body2 = L10n.tr("Localizable", "UX.onboarding.body2")
      /// You will get alerts about potential exposure to individuals with contagious illnesses.
      internal static let body3 = L10n.tr("Localizable", "UX.onboarding.body3")
      /// Help prevent the spread of contagious illnesses. Together, we can make a difference.
      internal static let body4 = L10n.tr("Localizable", "UX.onboarding.body4")
      /// How is my data used?
      internal static let how = L10n.tr("Localizable", "UX.onboarding.how")
      /// Get started
      internal static let join = L10n.tr("Localizable", "UX.onboarding.join")
      /// NEXT
      internal static let next = L10n.tr("Localizable", "UX.onboarding.next")
      /// Frequently asked questions
      internal static let questions = L10n.tr("Localizable", "UX.onboarding.questions")
      /// Log your interactions
      internal static let title1 = L10n.tr("Localizable", "UX.onboarding.title1")
      /// Monitor your health
      internal static let title2 = L10n.tr("Localizable", "UX.onboarding.title2")
      /// Stay informed
      internal static let title3 = L10n.tr("Localizable", "UX.onboarding.title3")
      /// Collaborate. Inform. Protect.
      internal static let title4 = L10n.tr("Localizable", "UX.onboarding.title4")
    }
    internal enum Permissions {
      internal enum Bt {
        /// Activating Bluetooth will enable CoEpi to detect interactions from nearby devices running compatible apps.
        internal static let body = L10n.tr("Localizable", "UX.permissions.BT.body")
        /// CoEpi would like to use Bluetooth
        internal static let title = L10n.tr("Localizable", "UX.permissions.BT.title")
      }
    }
    internal enum SymptomReport {
      /// Muscle aches
      internal static let ache = L10n.tr("Localizable", "UX.symptomReport.ache")
      /// Shortness of breath
      internal static let breathless = L10n.tr("Localizable", "UX.symptomReport.breathless")
      /// Cough
      internal static let cough = L10n.tr("Localizable", "UX.symptomReport.cough")
      /// Diarrhea
      internal static let diarrhea = L10n.tr("Localizable", "UX.symptomReport.diarrhea")
      /// Fever
      internal static let fever = L10n.tr("Localizable", "UX.symptomReport.fever")
      /// Symptom Report
      internal static let heading = L10n.tr("Localizable", "UX.symptomReport.heading")
      /// Loss of smell or taste
      internal static let loss = L10n.tr("Localizable", "UX.symptomReport.loss")
      /// Runny nose
      internal static let nose = L10n.tr("Localizable", "UX.symptomReport.nose")
      /// I don't have any symptoms today
      internal static let noSymptoms = L10n.tr("Localizable", "UX.symptomReport.noSymptoms")
      /// Other
      internal static let other = L10n.tr("Localizable", "UX.symptomReport.other")
      /// Select all that apply
      internal static let subtitle = L10n.tr("Localizable", "UX.symptomReport.subtitle")
      /// What symptoms do you have today?
      internal static let title = L10n.tr("Localizable", "UX.symptomReport.title")
    }
    internal enum Symptomsdays {
      /// Follow up: Earliest Symptoms
      internal static let heading = L10n.tr("Localizable", "UX.symptomsdays.heading")
      /// How many days ago did the symptoms begin?
      internal static let title = L10n.tr("Localizable", "UX.symptomsdays.title")
    }
    internal enum Thankyou {
      /// Thank you
      internal static let heading = L10n.tr("Localizable", "UX.thankyou.heading")
      /// Return to home screen
      internal static let home = L10n.tr("Localizable", "UX.thankyou.home")
      /// Log more symptoms
      internal static let more = L10n.tr("Localizable", "UX.thankyou.more")
      /// Thank you for logging your symptoms! We will alert if you have any relevant exposures to review.
      internal static let title = L10n.tr("Localizable", "UX.thankyou.title")
      /// View exposures
      internal static let viewExposures = L10n.tr("Localizable", "UX.thankyou.viewExposures")
    }
  }

  internal enum Alerts {
    /// What are exposure alerts?
    internal static let buttonLabel = L10n.tr("Localizable", "alerts.buttonLabel")
    /// Exposure Alerts
    internal static let header = L10n.tr("Localizable", "alerts.header")
    /// Exposure Alert
    internal static let moreInfoTitle = L10n.tr("Localizable", "alerts.moreInfoTitle")
    /// Click each alert to learn more
    internal static let subtitle = L10n.tr("Localizable", "alerts.subtitle")
    /// Alerts
    internal static let title = L10n.tr("Localizable", "alerts.title")
    internal enum Count {
      /// No new contact alerts
      internal static let `none` = L10n.tr("Localizable", "alerts.count.none")
      /// Click the alert to learn more
      internal static let one = L10n.tr("Localizable", "alerts.count.one")
      /// Click each alert to learn more
      internal static let some = L10n.tr("Localizable", "alerts.count.some")
    }
    internal enum Details {
      /// Exposure Alert
      internal static let title = L10n.tr("Localizable", "alerts.details.title")
      internal enum Distance {
        /// Approx. %1$s %2$s away from you
        internal static func avg(_ p1: UnsafePointer<CChar>, _ p2: UnsafePointer<CChar>) -> String {
          return L10n.tr("Localizable", "alerts.details.distance.avg", p1, p2)
        }
        internal enum Unit {
          /// Feet
          internal static let feet = L10n.tr("Localizable", "alerts.details.distance.unit.feet")
        }
      }
      internal enum Duration {
        /// %i hours and %i minutes exposure
        internal static func hoursMinutes(_ p1: Int, _ p2: Int) -> String {
          return L10n.tr("Localizable", "alerts.details.duration.hours_minutes", p1, p2)
        }
        /// %i minutes exposure
        internal static func minutes(_ p1: Int) -> String {
          return L10n.tr("Localizable", "alerts.details.duration.minutes", p1)
        }
        /// %i seconds exposure
        internal static func seconds(_ p1: Int) -> String {
          return L10n.tr("Localizable", "alerts.details.duration.seconds", p1)
        }
      }
      internal enum Label {
        /// Reported on %@ at %@
        internal static func reportedOn(_ p1: String, _ p2: String) -> String {
          return L10n.tr("Localizable", "alerts.details.label.reported_on", p1, p2)
        }
      }
    }
    internal enum Label {
      /// Archive
      internal static let archive = L10n.tr("Localizable", "alerts.label.archive")
      internal enum Symptom {
        /// Shortness of breath
        internal static let breathlessness = L10n.tr("Localizable", "alerts.label.symptom.breathlessness")
        /// Diarrhea
        internal static let diarrhea = L10n.tr("Localizable", "alerts.label.symptom.diarrhea")
        /// Loss of smell or taste
        internal static let lossSmellOrTaste = L10n.tr("Localizable", "alerts.label.symptom.lossSmellOrTaste")
        /// Muscle aches
        internal static let muscleAches = L10n.tr("Localizable", "alerts.label.symptom.muscleAches")
        /// No symptoms reported
        internal static let noSymptomsReported = L10n.tr("Localizable", "alerts.label.symptom.no_symptoms_reported")
        /// Other symptoms
        internal static let other = L10n.tr("Localizable", "alerts.label.symptom.other")
        /// Runny nose
        internal static let runnyNose = L10n.tr("Localizable", "alerts.label.symptom.runnyNose")
        internal enum Cough {
          /// Dry Cough
          internal static let dry = L10n.tr("Localizable", "alerts.label.symptom.cough.dry")
          /// Cough
          internal static let existing = L10n.tr("Localizable", "alerts.label.symptom.cough.existing")
          /// Wet Cough
          internal static let wet = L10n.tr("Localizable", "alerts.label.symptom.cough.wet")
        }
        internal enum Fever {
          /// Fever
          internal static let mild = L10n.tr("Localizable", "alerts.label.symptom.fever.mild")
          /// Fever
          internal static let serious = L10n.tr("Localizable", "alerts.label.symptom.fever.serious")
        }
      }
    }
    internal enum Notification {
      internal enum New {
        /// New contact alerts have been detected. Tap for details.
        internal static let body = L10n.tr("Localizable", "alerts.notification.new.body")
        /// New Contact Alerts
        internal static let title = L10n.tr("Localizable", "alerts.notification.new.title")
      }
    }
  }

  internal enum Home {
    internal enum Items {
      internal enum Alerts {
        internal enum Notification {
          /// 1 new exposure alert
          internal static let one = L10n.tr("Localizable", "home.items.alerts.notification.one")
          /// %d new exposure alerts
          internal static func some(_ p1: Int) -> String {
            return L10n.tr("Localizable", "home.items.alerts.notification.some", p1)
          }
        }
      }
    }
  }

  internal enum WhatExposure {
    /// <body><p><font color='black' face='-apple-system' size='5'><b>Exposure alerts</b> indicate that you have been in close proximity (e.g. within several feet) to someone with symptoms also using a compatible app. <br /><br /><b>How does CoEpi work?</b> <br /><br /> CoEpi generates exposure alerts if your device has flagged another tracing app user who may have been infectious during your contact. <br /><br /> Based on the symptom report in the exposure alert, you can: <br /><br /> <b>• Monitor</b> yourself for symptoms in the days following the potential exposure<br /><br /> <b>• Self-isolate</b> within your household to reduce the risk of transmitting to others <br /><br /> <b>• Talk with a healthcare provider</b> about your exposure</font</p><body>
    internal static let htmlBody = L10n.tr("Localizable", "whatExposure.html_body")
    /// What are exposure alerts?
    internal static let title = L10n.tr("Localizable", "whatExposure.title")
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
