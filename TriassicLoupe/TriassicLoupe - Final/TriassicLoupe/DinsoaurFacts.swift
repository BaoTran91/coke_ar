/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

struct DinosaurFact {
  let facts: [String]
  let titlePosition: (x: Float, y: Float)
  let name: String

  static let Brachiosaurus = DinosaurFact(facts: ["Herbivore", "Weighed 40 tons", "Name means \"arm reptile\""],
                                          titlePosition: (-0.2, 0.2),
                                          name: "Brachiosaurus")

  static let Iguanodon = DinosaurFact(facts: ["Name means \"iguana tooth\"", "Herbivore", "Weighed 3.5 tons"],
                                      titlePosition: (-0.15, 0.25),
                                      name: "Iguanodon")

  static let Velociraptor = DinosaurFact(facts: ["Weighed dozens of pounds", "Name means \"quick plunderer\"", "Late Cretaceous"],
                                         titlePosition: (-0.2, 0.3),
                                         name: "Velociraptor")

  static func facts(for name:String) -> DinosaurFact? {
    switch name {
    case "brachiosaurus":
      return .Brachiosaurus
    case "iguanodon":
      return .Iguanodon
    case "velociraptor":
      return .Velociraptor
    default:
      return nil
    }
  }

}
