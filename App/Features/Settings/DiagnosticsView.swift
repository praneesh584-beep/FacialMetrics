import SwiftUI
import UIKit

struct DiagnosticsView: View {
    @ObservedObject var buffer: DiagnosticBuffer
    @State private var showExportWarning = false

    var body: some View {
        List {
            Section {
                Text(PrivacyCopy.exportWarning)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                HStack {
                    Button {
                        UIPasteboard.general.string = buffer.exportText()
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)

                    ShareLink(item: buffer.exportText()) {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        buffer.clear()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            } header: {
                Text("Export")
            }

            Section("Latest Events") {
                ForEach(buffer.events.reversed()) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.level.rawValue.uppercased())
                                .font(.caption.weight(.semibold))
                            Spacer()
                            Text(event.timestamp.formatted(date: .omitted, time: .standard))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        Text(event.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(event.message)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Diagnostics")
    }
}
