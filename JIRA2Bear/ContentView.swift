import SwiftUI

struct ContentView: View {
    @State private var markdownText = ""

    var body: some View {
        VStack {
            Button("Load JIRA Issues") {
                loadJiraIssues { markdown in
                    self.markdownText = markdown
                }
            }
            TextEditor(text: $markdownText)
        }.padding()
    }

    func loadJiraIssues(completion: @escaping (String) -> Void) {
        let jiraAPIKey = "your_jira_api_key"
        let jiraUsername = "your_jira_username"
        let jiraURL = URL(string: "https://your_jira_instance.atlassian.net/rest/api/3/search?jql=assignee=currentuser()")!

        var request = URLRequest(url: jiraURL)
        request.setValue("Basic \(Data("\(jiraUsername):\(jiraAPIKey)".utf8).base64EncodedString())", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let issues = json["issues"] as? [[String: Any]] {
                        var markdown = ""
                        for issue in issues {
                            if let key = issue["key"] as? String, let fields = issue["fields"] as? [String: Any] {
                                let summary = fields["summary"] as? String ?? ""
                                let description = fields["description"] as? String ?? ""
                                markdown += "## \(key)\n\n**\(summary)**\n\n\(description)\n\n"
                            }
                        }
                        DispatchQueue.main.async {
                            completion(markdown)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }

        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
