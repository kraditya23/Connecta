import UIKit
import Flutter
import ContactsUI

@main
@objc class AppDelegate: FlutterAppDelegate, CNContactViewControllerDelegate {
  private let channelName = "my_app/contacts"
  var flutterResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

    methodChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      if call.method == "addOrUpdate" {
        guard let args = call.arguments as? [String: Any] else {
          result(false)
          return
        }
        self.flutterResult = result
        self.presentContactController(args: args)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func presentContactController(args: [String: Any]) {
    let contact = CNMutableContact()

    // 1) Full Name
    if let fullName = args["fullName"] as? String {
      let nameParts = fullName.split(separator: " ").map { String($0) }
      if nameParts.count >= 2 {
        contact.givenName  = nameParts.dropLast().joined(separator: " ")
        contact.familyName = nameParts.last!
      } else {
        contact.givenName = fullName
      }
    }

    // 2) Phone Numbers (all of them)
    if let phones = args["phones"] as? [String] {
      var phoneValues: [CNLabeledValue<CNPhoneNumber>] = []
      for number in phones where !number.trimmingCharacters(in: .whitespaces).isEmpty {
        let trimmed = number.trimmingCharacters(in: .whitespaces)
        let phoneValue = CNPhoneNumber(stringValue: trimmed)
        let labeledPhone = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneValue)
        phoneValues.append(labeledPhone)
      }
      if !phoneValues.isEmpty {
        contact.phoneNumbers = phoneValues
      }
    }

    // 3) Email Addresses (all of them)
    if let emails = args["emails"] as? [String] {
      var emailValues: [CNLabeledValue<NSString>] = []
      for email in emails where !email.trimmingCharacters(in: .whitespaces).isEmpty {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        let labeledEmail = CNLabeledValue(label: CNLabelWork, value: trimmed as NSString)
        emailValues.append(labeledEmail)
      }
      if !emailValues.isEmpty {
        contact.emailAddresses = emailValues
      }
    }

    // 4) Organization & Job Title
    if let org = args["organisation"] as? String, !org.isEmpty {
      contact.organizationName = org
    }
    if let title = args["jobTitle"] as? String, !title.isEmpty {
      contact.jobTitle = title
    }

    // 5) URLs (websites) – with custom labels
    if let websites = args["websites"] as? [[String: String]] {
      var urlValues: [CNLabeledValue<NSString>] = []
      for site in websites {
        guard let urlString = site["url"], !urlString.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
        let labelKey = (site["label"] ?? "Other").trimmingCharacters(in: .whitespaces)
        let labeledUrl = CNLabeledValue(label: labelKey, value: urlString as NSString)
        urlValues.append(labeledUrl)
      }
      if !urlValues.isEmpty {
        contact.urlAddresses = urlValues
      }
    }

    // 6) Notes: combine “location” + “aboutMe”
    var noteText = ""
    if let location = args["location"] as? String, !location.isEmpty {
      noteText += "Address: \(location)\n"
    }
    if let about = args["aboutMe"] as? String, !about.isEmpty {
      noteText += "About: \(about)"
    }
    if !noteText.isEmpty {
      contact.note = noteText
    }

    // 7) Present the “Add New Contact” UI
    let contactVC = CNContactViewController(forNewContact: contact)
    contactVC.delegate = self
    contactVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(dismissContactController)
    )

    let nav = UINavigationController(rootViewController: contactVC)
    nav.modalPresentationStyle = .fullScreen

    DispatchQueue.main.async {
      self.window?.rootViewController?.present(nav, animated: true) {
        self.flutterResult?(true)
        self.flutterResult = nil
      }
    }
  }

  @objc func dismissContactController() {
    window?.rootViewController?.dismiss(animated: true, completion: nil)
  }

  // Called when user taps “Save” or “Cancel”
  func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
    viewController.dismiss(animated: true, completion: nil)
  }
}