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
      /// Follow up: Breathlessness
      internal static let heading = L10n.tr("Localizable", "UX.breathless.heading")
      /// I am too breathless to leave the house or I am breathless when dressing
      internal static let p0 = L10n.tr("Localizable", "UX.breathless.p0")
      /// I stop for breath after walking about 100 yards or after a few minutes on level ground
      internal static let p1 = L10n.tr("Localizable", "UX.breathless.p1")
      /// On level ground, I have to stop for breath when walking at my own pace
      internal static let p2 = L10n.tr("Localizable", "UX.breathless.p2")
      /// I get short of breath when hurrying on level ground or walking up a slight hill
      internal static let p3 = L10n.tr("Localizable", "UX.breathless.p3")
      /// I only get breathless with strenuous exercise
      internal static let p4 = L10n.tr("Localizable", "UX.breathless.p4")
      /// Select one option
      internal static let subtitle = L10n.tr("Localizable", "UX.breathless.subtitle")
      /// I feel breathless when:
      internal static let title = L10n.tr("Localizable", "UX.breathless.title")
    }
    internal enum Cough {
      /// Felt better and worse throughout the day
      internal static let better = L10n.tr("Localizable", "UX.cough.better")
      /// Follow up: Cough
      internal static let heading = L10n.tr("Localizable", "UX.cough.heading")
      /// Stayed the same or felt steadily worse
      internal static let same = L10n.tr("Localizable", "UX.cough.same")
      /// Select all that apply
      internal static let subtitle3 = L10n.tr("Localizable", "UX.cough.subtitle3")
      /// \nMy throat feels 'tickly' or 'scratchy' without mucus
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
      ///     Exposure Alerts\n\n
      internal static let alerts1 = L10n.tr("Localizable", "UX.home.alerts1")
      ///     Find out reported alerts \n    around you
      internal static let alerts2 = L10n.tr("Localizable", "UX.home.alerts2")
      ///         new exposures detected\n\n
      internal static let detected = L10n.tr("Localizable", "UX.home.detected")
      /// How is my data being used?
      internal static let how = L10n.tr("Localizable", "UX.home.how")
      ///     My Symptom Report\n\n
      internal static let report1 = L10n.tr("Localizable", "UX.home.report1")
      ///     Track how you are feeling
      internal static let report2 = L10n.tr("Localizable", "UX.home.report2")
      /// CoEpi
      internal static let title = L10n.tr("Localizable", "UX.home.title")
    }
    internal enum Onboarding {
      /// Know if you’ve come in contact with others who may have been contagious based on proximity, arrival times, and departure times.
      internal static let body1 = L10n.tr("Localizable", "UX.onboarding.body1")
      /// Along with your community, monitor your health, and if relevant, the health of your family. Help in keeping yourself and others safe!
      internal static let body2 = L10n.tr("Localizable", "UX.onboarding.body2")
      /// Get contextualized alerts about exposure to transmissible illnesses, including locations and times, giving you time to seek medical attention.
      internal static let body3 = L10n.tr("Localizable", "UX.onboarding.body3")
      /// Halt the spread of contagious illnesses. View screening tests and results, find the right advice, and above all, understand and stop the spread of disease.
      internal static let body4 = L10n.tr("Localizable", "UX.onboarding.body4")
      /// How is my data used?
      internal static let how = L10n.tr("Localizable", "UX.onboarding.how")
      /// Join
      internal static let join = L10n.tr("Localizable", "UX.onboarding.join")
      /// NEXT
      internal static let next = L10n.tr("Localizable", "UX.onboarding.next")
      /// Frequently asked questions
      internal static let questions = L10n.tr("Localizable", "UX.onboarding.questions")
      /// Track where you’ve been.
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
      /// Breathlessness
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
      /// I have symptoms that are not on the list
      internal static let other = L10n.tr("Localizable", "UX.symptomReport.other")
      /// Select all that apply
      internal static let subtitle = L10n.tr("Localizable", "UX.symptomReport.subtitle")
      /// What symptoms do you have today?
      internal static let title = L10n.tr("Localizable", "UX.symptomReport.title")
    }
    internal enum Symptomsdays {
      /// Follow up: Symptoms Duration
      internal static let heading = L10n.tr("Localizable", "UX.symptomsdays.heading")
      /// How many days have you had any symptoms?
      internal static let title = L10n.tr("Localizable", "UX.symptomsdays.title")
    }
    internal enum Thankyou {
      /// Return to home screen
      internal static let home = L10n.tr("Localizable", "UX.thankyou.home")
      /// Log more symptoms
      internal static let more = L10n.tr("Localizable", "UX.thankyou.more")
      /// Thank you for saving your symptoms! We will keep you notified about exposures this week.
      internal static let title = L10n.tr("Localizable", "UX.thankyou.title")
      /// View exposures
      internal static let viewExposures = L10n.tr("Localizable", "UX.thankyou.viewExposures")
    }
  }

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
    internal enum Label {
      /// No symptoms reported
      internal static let noSymptomsReported = L10n.tr("Localizable", "alerts.label.no_symptoms_reported")
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
