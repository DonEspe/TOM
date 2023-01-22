//
//  ViewModel.swift
//  TOM
//
//  Created by Don Espe on 1/21/23.
//

import Foundation
import RegexBuilder

class ViewModel: ObservableObject {
    @Published var registers = [String: Int]()
    @Published var zx = 0

    @Published var log = ""
    private var lineNumber = 0

    func reset() {
        registers = [
            "AX": 0,
            "BX": 0,
            "CX": 0,
            "DX": 0,
            "EX": 0,
            "FX": 0,
            "GX": 0,
            "HX": 0
        ]

        zx = 0

        log = "Resetting all registers to their defaults..."
        lineNumber = 0
    }

    func run(code: String) {
        reset()

        guard code.isEmpty == false else { return }
        let movRegex = Regex { "MOV "; matchDigits(); ", "; matchRegister() }
        let addRegex = Regex { "ADD "; matchRegister(); ", "; matchRegister() }
        let subRegex = Regex { "SUB "; matchRegister(); ", "; matchRegister() }
        let copyRegex = Regex { "COPY "; matchRegister(); ", "; matchRegister() }
        let andRegex = Regex { "AND "; matchRegister(); ", "; matchRegister() }
        let orRegex = Regex { "OR "; matchRegister(); ", "; matchRegister() }
        let cmpRegex = Regex { "CMP "; matchRegister(); ", "; matchRegister() }
        let jeqRegex = Regex { "JEQ "; matchDigits() }
        let jneqRegex = Regex { "JNEQ "; matchDigits() }
        let jmpRegex = Regex { "JMP "; matchDigits() }

        let lines = code.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        var commandsUsed = 0

        while lineNumber < lines.count {
            let line = lines[lineNumber]

            if line.starts(with: "#") {
                lineNumber += 1
                continue
            }

            if let match = line.wholeMatch(of: movRegex) {
                mov(value: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: addRegex) {
                add(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: subRegex) {
                sub(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: copyRegex) {
                copy(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: andRegex) {
                and(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: orRegex) {
                or(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: cmpRegex) {
                cmp(source: match.output.1, destination: match.output.2)
            } else if let match = line.wholeMatch(of: jeqRegex) {
                jeq(to: match.output.1)
            } else if let match = line.wholeMatch(of: jneqRegex) {
                jneq(to: match.output.1)
            } else if let match = line.wholeMatch(of: jmpRegex) {
                jmp(to: match.output.1)
            } else {
                addToLog("*** ERROR: Unknown command. Remember: all commands and registers are case-sensitive ***")
                return
            }
            commandsUsed += 1
            lineNumber += 1

            guard commandsUsed < 10_000 else {
                addToLog("*** ERROR: Too many commands; exiting. ***")
                return
            }
        }
    }

    private func matchDigits() -> TryCapture<(Substring, Int)> {
        TryCapture {
            OneOrMore(.digit)
        } transform: { number in
            Int(number)
        }
    }

    private func matchRegister() -> Capture<(Substring, String)> {
        Capture {
            "A"..."H"
            "X"
        } transform: { match in
            String(match)
        }
    }

    private func addToLog(_ message: String) {
        log += "\nLine \(lineNumber + 1): \(message)"
    }

    private func clamp(register: String) {
        if registers[register, default: 0] < 0 {
            addToLog("*** Warning: Line \(lineNumber + 1) has set \(register) to a value below 0. It has been clamped to 0")
            registers[register] = 0
        } else if registers[register, default: 0] > 255 {
            addToLog("*** Warning: Line \(lineNumber + 1) has set \(register) to a value above 255. It has been clamped to 255")
            registers[register] = 255
        }
    }

    private func mov(value: Int, destination: String) {
        registers[destination] = value
        clamp(register: destination)
        addToLog("Moving \(value) into \(destination)")
    }

    private func add(source: String, destination: String) {
        registers[destination, default: 0] += registers[source, default: 0]
        clamp(register: destination)
        addToLog("Adding \(source) to \(destination)")
    }

    private func sub(source: String, destination: String) {
        registers[destination, default: 0] -= registers[source, default: 0]
        clamp(register: destination)
        addToLog("Subtracting \(source) to \(destination)")
    }

    private func copy(source: String, destination: String) {
        registers[destination, default: 0] = registers[source, default: 0]
        clamp(register: destination)
        addToLog("Copying \(source) to \(destination)")
    }

    private func and(source: String, destination: String) {
        registers[destination, default: 0] &= registers[source, default: 0]
        clamp(register: destination)
        addToLog("ANDing \(source) to \(destination)")
    }

    private func or(source: String, destination: String) {
        registers[destination, default: 0] |= registers[source, default: 0]
        clamp(register: destination)
        addToLog("ORing \(source) to \(destination)")
    }

    private func cmp(source: String, destination: String) {
        zx = registers[destination, default: 0] == registers[source, default: 0] ? 1 : 0
        clamp(register: destination)
        addToLog("Comparing \(source) to \(destination)")
    }

    private func jeq(to line: Int) {
        if zx == 1 {
            addToLog("ZX is 1 so jumping to line \(line)")
                     lineNumber = line - 2
        }
    }

    private func jneq(to line: Int) {
        if zx == 0 {
            addToLog("ZX is 0 so jumping to line \(line)")
            lineNumber = line - 2
        }
    }

    private func jmp(to line: Int) {
            addToLog("Jumping to line \(line)")
            lineNumber = line - 2
    }
}
