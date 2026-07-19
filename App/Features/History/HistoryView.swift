import SwiftUI

struct HistoryView: View {
    let store: ScanStore
    @State private var sessions: [ScanSession] = []
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                if sessions.isEmpty {
                    ContentUnavailableView("No Scans", systemImage: "clock", description: Text("Completed local scans will appear here."))
                } else {
                    ForEach(sessions) { session in
                        NavigationLink {
                            if let report = session.report {
                                ResultsView(report: report)
                            } else {
                                Text("This scan has no analysis report.")
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.createdAt.formatted(date: .abbreviated, time: .shortened))
                                Text("\(session.acceptedSamples.count) accepted samples")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        load()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Reload history")
                }
            }
            .task { load() }
        }
    }

    private func load() {
        do {
            sessions = try store.loadAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func delete(offsets: IndexSet) {
        do {
            for index in offsets {
                try store.delete(sessions[index])
            }
            load()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
