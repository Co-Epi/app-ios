import Foundation

class CoEpiAPI {
  let server = "coepi.wolk.com"
  let httpport = "8080"
  
    private func generateEndpoint(action: String) -> String {
        return "https://" + self.server + ":" + httpport + "/" + action
    }
    
    func postCENReport(cenreport: CENReport) {
        let endpoint = generateEndpoint(action: "cenreport")
        let method = "POST"
        let encodedCENReport = try! JSONEncoder().encode(cenreport)
        makeAPICall(endpoint: endpoint, method: method, body: encodedCENReport)
    }

    func sendExposureAndSymptoms(eas: ExposureAndSymptoms) {
        let endpoint = generateEndpoint(action: "exposureandsymptoms")
        let method = "POST"
        let encodedEAS = try! JSONEncoder().encode(eas)
        makeAPICall(endpoint: endpoint, method: method, body: encodedEAS)
    }
      
    func sendExposureCheck(ec: ExposureCheck) {
        let endpoint = generateEndpoint(action: "exposurecheck")
        let method = "POST"
        let encodedEC = try! JSONEncoder().encode(ec)
        makeAPICall(endpoint: endpoint, method: method, body: encodedEC)
    }

    private func makeAPICall(endpoint: String, method: String, body: Data) {

         //var error: Unmanaged<CFError>?
         let config = URLSessionConfiguration.default
         config.waitsForConnectivity = true
         guard let URLObject = URL(string: endpoint) else {

             return
         }
         var req = URLRequest(url: URLObject)
         req.httpMethod = method
         req.httpBody = body
         
         URLSession(configuration: config).dataTask(with: req) { data, response, error in
             if let error = error {
                 print(error.localizedDescription)
             }

             // TODO: on Wait, use a long timeout, but not for all the others!

             if let error = error {
                 //TODO: self.handleClientError(error)
                 print("ERROR: \(error)")
                 //errorHandler(error)
                 return
             }
             guard let httpResponse = response as? HTTPURLResponse,
                 (200...299).contains(httpResponse.statusCode) else {
                 //TODO: self.handleServerError(response)
                 return
             }
             
             //TODO: determine where/when this should / can be called
             //successHandler(data, httpResponse)
         }.resume()
  }
}
