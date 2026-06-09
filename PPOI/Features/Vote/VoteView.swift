import SwiftUI

struct VoteView: View {
    let date: String
    let accentColor: Color

    @State private var counts = VoteCounts()
    @State private var selectedReaction: Reaction?
    @State private var didLoad = false
    @State private var animatingReaction: Reaction?

    private let service = VoteService()

    var body: some View {
        VStack(spacing: 8) {
            Text("今日の格言、どうだった？")
                .font(.caption)
                .foregroundStyle(accentColor.opacity(0.7))

            HStack(spacing: 16) {
                ForEach(Reaction.allCases) { reaction in
                    reactionButton(reaction)
                }
            }

            if counts.total > 0 {
                Text("\(counts.total)人が反応")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .task {
            guard !didLoad else { return }
            didLoad = true
            selectedReaction = loadLocalVote()
            counts = await service.fetchCounts(for: date)
        }
    }

    private func reactionButton(_ reaction: Reaction) -> some View {
        Button {
            castVote(reaction)
        } label: {
            VStack(spacing: 2) {
                Text(reaction.emoji)
                    .font(.title2)
                    .scaleEffect(animatingReaction == reaction ? 1.4 : 1.0)
                Text("\(counts.count(for: reaction))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                selectedReaction == reaction
                    ? accentColor.opacity(0.15)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedReaction)
        .accessibilityLabel("\(reaction.emoji)リアクション、\(counts.count(for: reaction))票")
        .accessibilityAddTraits(selectedReaction == reaction ? .isSelected : [])
    }

    private func castVote(_ reaction: Reaction) {
        let previous = selectedReaction
        if previous == reaction { return }

        // Optimistic local update
        if let prev = previous {
            updateLocalCount(prev, delta: -1)
        }
        updateLocalCount(reaction, delta: 1)
        selectedReaction = reaction
        saveLocalVote(reaction)

        // Scale animation
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            animatingReaction = reaction
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5).delay(0.2)) {
            animatingReaction = nil
        }

        Task {
            await service.vote(date: date, reaction: reaction, previousReaction: previous)
        }
    }

    private func updateLocalCount(_ reaction: Reaction, delta: Int) {
        switch reaction {
        case .thinking: counts.thinking += delta
        case .laughing: counts.laughing += delta
        case .crying: counts.crying += delta
        case .fire: counts.fire += delta
        }
    }

    // MARK: - Local persistence (1 vote per day)

    private func loadLocalVote() -> Reaction? {
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: "votedDate") == date,
              let raw = defaults.string(forKey: "votedReaction")
        else { return nil }
        return Reaction(rawValue: raw)
    }

    private func saveLocalVote(_ reaction: Reaction) {
        let defaults = UserDefaults.standard
        defaults.set(date, forKey: "votedDate")
        defaults.set(reaction.rawValue, forKey: "votedReaction")
    }
}
