//var body: some View {
//    NavigationStack {
//        VStack {
//            HStack {
//                Spacer()
//                Text("Glossary").font(.largeTitle)
//                Spacer()
//                Button("Add") {
//                    self.showModal.toggle()
//                }.padding()
//            }
//            SearchBar(text: $searchTerm)
//            List {
//                // 시작할 때, 단어 전부 가져와서 보여주기. 여기가 바뀌어야 함.
//                ForEach(words.filter {
//                    self.searchTerm.isEmpty ? true : $0.text.localizedStandardContains(self.searchTerm)
//                }) { word in
//                    HStack {
//                        NavigationLink(destination: WordDetailView(word: word)) {
//                            Text(word.text)
//                        }
//                    }
//                }
//                .onDelete(perform: deleteWord)
//            }
//        }
//        .sheet(isPresented: $showModal) {
//            VStack {
//                HStack {
//                    Text("Word")
//                    Spacer()
//                    TextField("Enter Word", text: self.$newWord)
//                }
//                HStack {
//                    Text("Definition")
//                    Spacer()
//                    TextField("Enter Definition", text: self.$newDefinition)
//                }
//                Button("Save") {
//                    self.addWord()
//                    self.showModal.toggle()
//                }
//            }
//        }
//    }
//    .onAppear {
//        self.getWordList()
//    }
//}
//


//func getWordList() {
//    let url = URL(string: "http://localhost:3000/words")!
//    URLSession.shared.dataTask(with: url) { (data, response, error) in
//        if let error = error {
//            print(error)
//            return
//        }
//
//        if let data = data {
//            let decoder = JSONDecoder()
//            if let wordList = try? decoder.decode([Word].self, from: data) {
//                DispatchQueue.main.async {
//                    self.words = wordList
//                }
//            }
//        }
//    }.resume()
//}


//func getWordList() {
//    let endpoint = URL(string: "http://localhost:3000/graphql")!
//    var request = URLRequest(url: endpoint)
//    request.httpMethod = "POST"
//    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    let query = "{ words { word } }"
//
//    let body: [String: Any] = [
//        "query": query
//    ]
//
//    request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//    URLSession.shared.dataTask(with: request) { (data, response, error) in
//        if let error = error {
//            print(error)
//            return
//        }
//
//        if let data = data {
//            let decoder = JSONDecoder()
//            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                let wordList = json?["data"] as? [[String: Any]]
//                DispatchQueue.main.async {
//                    self.words = wordList
//                }
//            } catch {
//                print(error)
//            }
//        }
//    }.resume()
//}



//    func addWord() {
//        if !newWord.isEmpty && !newDefinition.isEmpty {
//            let url = URL(string: "http://localhost:8080/addword")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let word = ["text": newWord, "definition": newDefinition]
//            let data = try! JSONEncoder().encode(word)
//            request.httpBody = data
//
//            URLSession.shared.dataTask(with: request) { (data, response, error) in
//                if let error = error {
//                    print(error.localizedDescription)
//                    return
//                }
//                if let response = response as? HTTPURLResponse, response.statusCode != 200 {
//                    print("Status code: \(response.statusCode)")
//                    return
//                }
//                if let data = data {
//                    print(String(data: data, encoding: .utf8)!)
//                }
//            }.resume()
//
//            words.append(Word(text: newWord, definition: newDefinition))
//            newWord = ""
//            newDefinition = ""
//        }
//    }
