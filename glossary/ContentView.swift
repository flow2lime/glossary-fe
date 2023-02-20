import SwiftUI
import Apollo

struct GlossaryView: View {
    @State private var words = [Word]()
    @State private var newWord = ""
    @State private var newDescription = ""
    @State private var showModal = false
    @State private var searchTerm = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Text("Glossary").font(.largeTitle)
                    Spacer().frame(width: 90)
                    Button("Add") {
                        self.showModal.toggle()
                    }.padding()
                }
                SearchBar(text: $searchTerm)
                VStack {
                    List {
                        ForEach(words.filter {
                            self.searchTerm.isEmpty ? true : $0.name.localizedStandardContains(self.searchTerm)
                        }) { word in
                            HStack {
                                NavigationLink(destination: WordDetailView(word: word)) {
                                    Text(word.name)
                                }
                            }
                        }
                        .onDelete(perform: deleteWord)
                    }
                }

            }
            .sheet(isPresented: $showModal) {
                VStack {
                    HStack {
                        Text("Word")
                        Spacer()
                        TextField("Enter Word", text: self.$newWord)
                    } // TODO: 옅은 회색의 텍스트 인풋 박스 넣기
                    HStack {
                        Text("Definition")
                        Spacer()
                        TextField("Enter Definition", text: self.$newDescription)
                    }
                    Button("Save") {
                        self.addWordV2()
                        self.showModal.toggle()
                        self.getWordList()
                    }
                }
            }
        }.onAppear {
            self.getWordList()
        }
    }
    
    func getWordList() {
        let endpoint = URL(string: "http://localhost:3002/graphql")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let query = """
        {
            terms {
                id
                name
                description
            }
        }
        """

        let body: [String: Any] = [
            "query": query
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }

            if let data = data {
                print("")
                do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        if let dictionary = json as? [String: Any] {
                            print(dictionary)
                            if let termDict = dictionary["data"] as? [String: Any] {
                                print(termDict)
                                if let terms = termDict["terms"] as? [[String: Any]] {
                                    let wordList = terms.compactMap { Word(name: $0["name"] as? String ?? "", description: $0["description"] as? String ?? "") }
                                    print(wordList)
                                    DispatchQueue.main.async {
                                        self.words = wordList
                                    }

                                    print("wordList: \(String(describing: wordList))")
                                } else {
                                    print("1st error: Unable to cast JSON to [String: Any]")
                                }
                            }
                        } else {
                            print("2nd error: Unable to cast JSON to [String: Any]")
                        }
                    } catch {
                        print("3rd error : \(error)")
                    }
            }
        }.resume()
    }


//    func addWord() {
//        if !newWord.isEmpty && !newDescription.isEmpty {
//            words.append(Word(name: newWord, description: newDescription))
//            newWord = ""
//            newDescription = ""
//        }
//    }
    
    func addWordV2() {
        let endpoint = URL(string: "http://localhost:3002/graphql")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let mutation = """
        mutation AddTerm($name: String!, $description: String!) {
            addTerm( newTermData: {
                name: $name
                description: $description
            }) {
                id
                name
                description
            }
        }
        """
        
        
        let variables = ["name": newWord, "description": newDescription]
        let body: [String: Any] = [
            "query": mutation,
            "variables": variables
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let data = data {
                // Parse the JSON response to extract the new word data
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let result = try decoder.decode(Word.self, from: data)
                    DispatchQueue.main.async {
                        self.words.append(Word(name: result.name, description: result.description))
                        self.newWord = ""
                        self.newDescription = ""
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    

    func deleteWord(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
    }
}


struct WordDetailView: View {
    var word: Word

    var body: some View {
        VStack {
            VStack {
                Text(word.name).font(.largeTitle).padding(.top)
                
            }
            HStack {
                Button(action: {
                    // Delete word action here
                }) {
                    Text("Delete")
                }.padding()
                Spacer()
                Button(action: {
                    // Edit word action here
                }) {
                    Text("Edit")
                }.padding()
            }
            Spacer()
            Text(word.description).font(.title2).padding()
            Spacer()
        }
    }
}




struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.leading, 10)
                .frame(height: 50)
            Button(action: {
                self.text = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(text == "" ? 0 : 1)
            }
            .padding(.trailing, 10)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.leading, 10)
        .padding(.trailing, 10)
    }
}

struct Word: Identifiable, Decodable {
    var id = UUID()
    let name: String
    let description: String
}


struct NoteView_Previews: PreviewProvider {
    static var previews: some View {
        GlossaryView()
    }
}
